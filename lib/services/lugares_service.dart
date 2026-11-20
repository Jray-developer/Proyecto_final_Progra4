import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/lugar.dart';

class LugaresService {
  
  // 1. Obtener todos los lugares (ordenados del más reciente al más antiguo)[cite: 3]
  Future<List<Lugar>> obtenerLugares() async {
    final url = Uri.parse('${Config.supabaseUrl}/lugares?select=*&order=creado_en.desc');
    
    final response = await http.get(
      url,
      headers: {
        'apikey': Config.supabaseKey,
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Lugar.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los lugares (Código: ${response.statusCode})');
    }
  }

  // 2. Obtener solo "Mis lugares" filtrados por tu carné[cite: 2, 3]
  Future<List<Lugar>> obtenerMisLugares() async {
    final url = Uri.parse('${Config.supabaseUrl}/lugares?select=*&carne=eq.${Config.carne}');
    
    final response = await http.get(
      url,
      headers: {
        'apikey': Config.supabaseKey,
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Lugar.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar tus lugares (Código: ${response.statusCode})');
    }
  }

  // 3. Crear un nuevo lugar (Usa POST y requiere el código personal x-codigo)[cite: 2, 3]
  Future<Lugar> crearLugar(Lugar lugar) async {
    final url = Uri.parse('${Config.supabaseUrl}/lugares');
    
    // Forzamos que se envíe tu carné institucional
    final Map<String, dynamic> bodyData = lugar.toJson();
    bodyData['carne'] = Config.carne;

    final response = await http.post(
      url,
      headers: {
        'apikey': Config.supabaseKey,
        'x-codigo': Config.codigoPersonal,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation', // Devuelve el registro afectado[cite: 3]
      },
      body: jsonEncode(bodyData),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return Lugar.fromJson(jsonList[0]);
    } else if (response.statusCode == 400) {
      throw Exception('Un dato no cumple con las reglas de la base de datos.');
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Error de autenticación o código personal incorrecto.');
    } else {
      throw Exception('No se pudo crear el lugar (Código: ${response.statusCode})');
    }
  }

  // 4. Editar un lugar existente por su id (Usa PATCH y x-codigo)[cite: 2, 3]
  Future<void> editarLugar(int id, Lugar lugar) async {
    final url = Uri.parse('${Config.supabaseUrl}/lugares?id=eq.$id');

    final response = await http.patch(
      url,
      headers: {
        'apikey': Config.supabaseKey,
        'x-codigo': Config.codigoPersonal,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: jsonEncode(lugar.toJson()),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Si responde con lista vacía [], significa que no existe o no es tuyo[cite: 3]
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isEmpty) {
          throw Exception('No puedes modificar este lugar');
        }
      }
    } else {
      throw Exception('Error al actualizar el lugar (Código: ${response.statusCode})');
    }
  }

  // 5. Eliminar un lugar por su id (Usa DELETE y x-codigo)[cite: 2, 3]
  Future<void> eliminarLugar(int id) async {
    final url = Uri.parse('${Config.supabaseUrl}/lugares?id=eq.$id');

    final response = await http.delete(
      url,
      headers: {
        'apikey': Config.supabaseKey,
        'x-codigo': Config.codigoPersonal,
        'Prefer': 'return=representation',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isEmpty) {
          throw Exception('No puedes eliminar este lugar');
        }
      }
    } else {
      throw Exception('Error al eliminar el lugar (Código: ${response.statusCode})');
    }
  }
}