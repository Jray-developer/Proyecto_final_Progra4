import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/clima.dart';

class ClimaService {
  
  // Consulta el pronóstico del clima para un lugar y fecha específicos[cite: 3, 4]
  Future<Clima> obtenerPronostico(double latitud, double longitud, String fecha) async {
    // Construimos la URL con los parámetros requeridos por Open-Meteo
    final url = Uri.parse(
      '${Config.openMeteoUrl}'
      '?latitude=$latitud'
      '&longitude=$longitud'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max,weather_code'
      '&timezone=America%2FGuatemala'
      '&start_date=$fecha'
      '&end_date=$fecha'
    );

    try {
      // Realizamos la petición HTTP con un tiempo de espera (timeout) por seguridad[cite: 4, 6]
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);
        return Clima.fromJson(jsonBody);
      } else if (response.statusCode == 400) {
        throw Exception('La fecha seleccionada está fuera del rango de pronóstico disponible (máximo 16 días).');
      } else {
        throw Exception('No se pudo obtener el pronóstico del clima (Código: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de red: No fue posible conectar con Open-Meteo. Verifica tu conexión a internet.');
    }
  }
}