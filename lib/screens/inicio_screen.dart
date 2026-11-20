import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../services/lugares_service.dart';
import 'form_lugar_screen.dart';
import 'detalle_clima_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final LugaresService _lugaresService = LugaresService();
  
  List<Lugar> _lugares = [];
  bool _cargando = true;
  String? _error;
  bool _verSoloMisLugares = false;

  @override
  void initState() {
    super.initState();
    _cargarLugares();
  }

  // Carga o recarga la lista de lugares según el filtro seleccionado
  Future<void> _cargarLugares() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = _verSoloMisLugares
          ? await _lugaresService.obtenerMisLugares()
          : await _lugaresService.obtenerLugares();

      if (mounted) {
        setState(() {
          _lugares = lista;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _cargando = false;
        });
      }
    }
  }

  // Diálogo de confirmación antes de eliminar un lugar propio
  Future<void> _confirmarEliminacion(Lugar lugar) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${lugar.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true && lugar.id != null) {
      try {
        await _lugaresService.eliminarLugar(lugar.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lugar eliminado correctamente')),
          );
          _cargarLugares();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explora Verapaz 🏞️'),
        actions: [
          IconButton(
            icon: Icon(_verSoloMisLugares ? Icons.person : Icons.public),
            tooltip: _verSoloMisLugares ? 'Ver todos los lugares' : 'Ver mis lugares',
            onPressed: () {
              setState(() {
                _verSoloMisLugares = !_verSoloMisLugares;
              });
              _cargarLugares();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargarLugares,
          ),
        ],
      ),
      body: _buildContenido(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final creoNuevo = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const FormLugarScreen()),
          );
          if (creoNuevo == true) {
            _cargarLugares();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Lugar'),
      ),
    );
  }

  // Manejo explícito de los 4 estados: Cargando, Error, Vacío y Datos
  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Consultando lugares...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarLugares,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lugares.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _verSoloMisLugares
                  ? 'Aún no has registrado ningún lugar.'
                  : 'No hay lugares registrados en la base de datos.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _lugares.length,
      itemBuilder: (context, index) {
        final lugar = _lugares[index];
        final esPropio = lugar.carne == '000150571'; // Identifica tus lugares creados

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(
                _getIconoTipo(lugar.tipo),
                color: Colors.teal.shade800,
              ),
            ),
            title: Text(lugar.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${lugar.municipio ?? 'Alta Verapaz'} • Tipo: ${lugar.tipo}'),
                Text('Carné: ${lugar.carne} | Origen: ${lugar.origen}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            isThreeLine: true,
            trailing: esPropio
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final edito = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormLugarScreen(lugarParaEditar: lugar),
                            ),
                          );
                          if (edito == true) _cargarLugares();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarEliminacion(lugar),
                      ),
                    ],
                  )
                : const Icon(Icons.chevron_right),
            onTap: () {
              // Abrir pantalla de detalle y clima
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleClimaScreen(lugar: lugar),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'naturaleza':
        return Icons.park;
      case 'cueva':
        return Icons.landscape;
      case 'rio':
        return Icons.water;
      case 'cultura':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }
}