import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../services/lugares_service.dart';
import '../services/ubicacion_service.dart';

class FormLugarScreen extends StatefulWidget {
  final Lugar? lugarParaEditar;

  const FormLugarScreen({super.key, this.lugarParaEditar});

  @override
  State<FormLugarScreen> createState() => _FormLugarScreenState();
}

class _FormLugarScreenState extends State<FormLugarScreen> {
  final _formKey = GlobalKey<FormState>();
  final LugaresService _lugaresService = LugaresService();
  final UbicacionService _ubicacionService = UbicacionService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _municipioCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _latitudCtrl;
  late TextEditingController _longitudCtrl;

  String _tipoSeleccionado = 'naturaleza';
  String _origen = 'manual';
  bool _guardando = false;
  bool _obteniendoGps = false;

  final List<String> _tiposPermitidos = ['naturaleza', 'cueva', 'rio', 'cultura', 'otro'];

  @override
  void initState() {
    super.initState();
    final l = widget.lugarParaEditar;
    _nombreCtrl = TextEditingController(text: l?.nombre ?? '');
    _municipioCtrl = TextEditingController(text: l?.municipio ?? '');
    _descripcionCtrl = TextEditingController(text: l?.descripcion ?? '');
    _latitudCtrl = TextEditingController(text: l?.latitud.toString() ?? '');
    _longitudCtrl = TextEditingController(text: l?.longitud.toString() ?? '');
    if (l != null && _tiposPermitidos.contains(l.tipo)) {
      _tipoSeleccionado = l.tipo;
    }
    _origen = l?.origen ?? 'manual';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _municipioCtrl.dispose();
    _descripcionCtrl.dispose();
    _latitudCtrl.dispose();
    _longitudCtrl.dispose();
    super.dispose();
  }

  // Usa la ubicación GPS para llenar las coordenadas automáticamente
  Future<void> _usarUbicacionGPS() async {
    setState(() => _obteniendoGps = true);
    try {
      final pos = await _ubicacionService.obtenerUbicacionActual();
      setState(() {
        _latitudCtrl.text = pos.latitude.toStringAsFixed(6);
        _longitudCtrl.text = pos.longitude.toStringAsFixed(6);
        _origen = 'gps'; // Marca origen como GPS
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordenadas obtenidas mediante GPS')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _obteniendoGps = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final lat = double.parse(_latitudCtrl.text.trim());
      final lon = double.parse(_longitudCtrl.text.trim());

      final lugarData = Lugar(
        carne: '000150571',
        nombre: _nombreCtrl.text.trim(),
        municipio: _municipioCtrl.text.trim(),
        tipo: _tipoSeleccionado,
        descripcion: _descripcionCtrl.text.trim(),
        latitud: lat,
        longitud: lon,
        origen: _origen,
      );

      if (widget.lugarParaEditar == null) {
        await _lugaresService.crearLugar(lugarData);
      } else {
        await _lugaresService.editarLugar(widget.lugarParaEditar!.id!, lugarData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.lugarParaEditar == null ? 'Lugar registrado' : 'Lugar actualizado')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.lugarParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Lugar' : 'Nuevo Lugar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Nombre obligatorio (2 a 100 caracteres)
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del lugar *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 2 || v.trim().length > 100) {
                    return 'El nombre debe tener entre 2 y 100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Municipio (Opcional, máx 80)
              TextFormField(
                controller: _municipioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Municipio (ej: Lanquín, Cobán)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) {
                  if (v != null && v.trim().length > 80) {
                    return 'El municipio no puede exceder los 80 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Tipo (Lista predefinida)
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de lugar *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _tiposPermitidos.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.toUpperCase()));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tipoSeleccionado = val);
                },
              ),
              const SizedBox(height: 16),

              // 4. Descripción (Opcional, máx 500)
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción del lugar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) {
                  if (v != null && v.trim().length > 500) {
                    return 'La descripción no puede exceder los 500 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Botón de GPS
              OutlinedButton.icon(
                onPressed: _obteniendoGps ? null : _usarUbicacionGPS,
                icon: _obteniendoGps
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: const Text('Usar mi ubicación actual (GPS)'),
              ),
              const SizedBox(height: 12),

              // 5. Coordenadas válidas (Latitud: -90 a 90, Longitud: -180 a 180)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Latitud *', border: OutlineInputBorder()),
                      onChanged: (_) => _origen = 'manual',
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val < -90 || val > 90) {
                          return 'Latitud entre -90 y 90';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Longitud *', border: OutlineInputBorder()),
                      onChanged: (_) => _origen = 'manual',
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val < -180 || val > 180) {
                          return 'Longitud entre -180 y 180';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(esEdicion ? 'Actualizar Lugar' : 'Guardar Lugar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}