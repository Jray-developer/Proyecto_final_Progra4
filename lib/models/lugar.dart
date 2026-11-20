class Lugar {
  final int? id;
  final String carne;
  final String nombre;
  final String? municipio;
  final String tipo;
  final String? descripcion;
  final double latitud;
  final double longitud;
  final String origen;
  final String? creadoEn;
  final String? actualizadoEn;

  Lugar({
    this.id,
    required this.carne,
    required this.nombre,
    this.municipio,
    required this.tipo,
    this.descripcion,
    required this.latitud,
    required this.longitud,
    this.origen = 'manual',
    this.creadoEn,
    this.actualizadoEn,
  });

  // 1. DESERIALIZAR: Convierte el Map/JSON que responde Supabase en un objeto Lugar de Dart[cite: 10]
  factory Lugar.fromJson(Map<String, dynamic> json) {
    return Lugar(
      id: json['id'],
      carne: json['carne'] ?? '',
      nombre: json['nombre'] ?? '',
      municipio: json['municipio'],
      tipo: json['tipo'] ?? 'otro',
      descripcion: json['descripcion'],
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      origen: json['origen'] ?? 'manual',
      creadoEn: json['creado_en'],
      actualizadoEn: json['actualizado_en'],
    );
  }

  // 2. SERIALIZAR: Prepara el objeto Lugar de Dart en formato Map para enviarlo en un POST o PATCH[cite: 10]
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'carne': carne,
      'nombre': nombre,
      'tipo': tipo,
      'latitud': latitud,
      'longitud': longitud,
      'origen': origen,
    };

    // Solo enviamos los opcionales si tienen contenido para evitar errores en la API
    if (municipio != null && municipio!.trim().isNotEmpty) {
      data['municipio'] = municipio;
    }
    if (descripcion != null && descripcion!.trim().isNotEmpty) {
      data['descripcion'] = descripcion;
    }

    return data;
  }

  // 3. copyWith: Permite clonar el objeto cambiando solo los campos que deseemos (muy útil al editar)[cite: 45]
  Lugar copyWith({
    int? id,
    String? carne,
    String? nombre,
    String? municipio,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    String? origen,
    String? creadoEn,
    String? actualizadoEn,
  }) {
    return Lugar(
      id: id ?? this.id,
      carne: carne ?? this.carne,
      nombre: nombre ?? this.nombre,
      municipio: municipio ?? this.municipio,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      origen: origen ?? this.origen,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }
}