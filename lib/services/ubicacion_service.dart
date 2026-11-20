import 'package:geolocator/geolocator.dart';

class UbicacionService {
  // Obtiene la ubicación actual del dispositivo gestionando permisos y servicios de GPS
  Future<Position> obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si los servicios de ubicación están activados en el teléfono
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación (GPS) están desactivados. Por favor actívalos.');
    }

    // 2. Verificar el estado de los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('El permiso de ubicación fue denegado.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están denegados permanentemente. Actívalos desde Ajustes.');
    }

    // 3. Obtener la posición con precisión deseada
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}