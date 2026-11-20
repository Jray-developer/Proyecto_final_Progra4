import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lugar.dart';
import '../models/clima.dart';
import '../services/clima_service.dart';

class DetalleClimaScreen extends StatefulWidget {
  final Lugar lugar;

  const DetalleClimaScreen({super.key, required this.lugar});

  @override
  State<DetalleClimaScreen> createState() => _DetalleClimaScreenState();
}

class _DetalleClimaScreenState extends State<DetalleClimaScreen> {
  final ClimaService _climaService = ClimaService();

  DateTime _fechaSeleccionada = DateTime.now();
  Clima? _clima;
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _consultarClima();
  }

  // Petición a Open-Meteo controlando el rango máximo de días
  Future<void> _consultarClima() async {
    final hoy = DateTime.now();
    final fechaMax = hoy.add(const Duration(days: 15));

    // Validar rango de pronóstico antes de consultar
    if (_fechaSeleccionada.isBefore(hoy.subtract(const Duration(days: 1))) || _fechaSeleccionada.isAfter(fechaMax)) {
      setState(() {
        _error = 'El pronóstico solo está disponible para los próximos 16 días.';
        _clima = null;
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);

    try {
      final climaRes = await _climaService.obtenerPronostico(
        widget.lugar.latitud,
        widget.lugar.longitud,
        fechaStr,
      );

      if (mounted) {
        setState(() {
          _clima = climaRes;
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

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 15)),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
      _consultarClima();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lugar.nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta con info general del lugar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.lugar.nombre, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('Municipio: ${widget.lugar.municipio ?? "N/A"}'),
                    Text('Tipo: ${widget.lugar.tipo.toUpperCase()}'),
                    Text('Coordenadas: ${widget.lugar.latitud}, ${widget.lugar.longitud}'),
                    if (widget.lugar.descripcion != null && widget.lugar.descripcion!.isNotEmpty) ...[
                      const Divider(),
                      Text('Descripción: ${widget.lugar.descripcion}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selector de fecha de visita
            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: const Text('Fecha de tu visita'),
                subtitle: Text(DateFormat('EEEE d MMMM, yyyy', 'es').format(_fechaSeleccionada)),
                trailing: ElevatedButton(
                  onPressed: _seleccionarFecha,
                  child: const Text('Cambiar'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta de Clima e información
            _buildWidgetClima(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetClima() {
    if (_cargando) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _consultarClima,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              )
            ],
          ),
        ),
      );
    }

    if (_clima == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_clima!.descripcionClima, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.thermostat, color: Colors.red),
                    Text('Máx: ${_clima!.tempMax}°C'),
                    Text('Mín: ${_clima!.tempMin}°C'),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.umbrella, color: Colors.blue),
                    Text('Lluvia: ${_clima!.probabilidadLluvia}%'),
                    Text('${_clima!.lluviaSum} mm'),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.air, color: Colors.grey),
                    Text('Viento: ${_clima!.vientoMax} km/h'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _clima!.recomendacion,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}