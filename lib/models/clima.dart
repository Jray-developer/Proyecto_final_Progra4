class Clima {
  final String fecha;
  final double tempMax;
  final double tempMin;
  final int probabilidadLluvia;
  final double lluviaSum;
  final double vientoMax;
  final int weatherCode;

  Clima({
    required this.fecha,
    required this.tempMax,
    required this.tempMin,
    required this.probabilidadLluvia,
    required this.lluviaSum,
    required this.vientoMax,
    required this.weatherCode,
  });

  // Deserializa la respuesta de Open-Meteo (que viene estructurada en listas dentro de "daily")
  factory Clima.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] ?? {};

    // Extraemos el primer elemento de las listas que devuelve Open-Meteo para la fecha consultada
    final List times = daily['time'] ?? [''];
    final List tMax = daily['temperature_2m_max'] ?? [0.0];
    final List tMin = daily['temperature_2m_min'] ?? [0.0];
    final List pProb = daily['precipitation_probability_max'] ?? [0];
    final List pSum = daily['precipitation_sum'] ?? [0.0];
    final List wWind = daily['wind_speed_10m_max'] ?? [0.0];
    final List wCode = daily['weather_code'] ?? [0];

    return Clima(
      fecha: times.isNotEmpty ? times[0].toString() : '',
      tempMax: (tMax[0] as num?)?.toDouble() ?? 0.0,
      tempMin: (tMin[0] as num?)?.toDouble() ?? 0.0,
      probabilidadLluvia: (pProb[0] as num?)?.toInt() ?? 0,
      lluviaSum: (pSum[0] as num?)?.toDouble() ?? 0.0,
      vientoMax: (wWind[0] as num?)?.toDouble() ?? 0.0,
      weatherCode: (wCode[0] as num?)?.toInt() ?? 0,
    );
  }

  // 💡 Recomendación inteligente basada en las reglas del proyecto (ej: probabilidad de lluvia > 60%)
  String get recomendacion {
    if (probabilidadLluvia > 60) {
      return 'Alta probabilidad de lluvia (${probabilidadLluvia}%). ¡Lleva impermeable!';
    } else if (tempMax > 30.0) {
      return 'Temperatura máxima de ${tempMax}°C. Lleva agua y bloqueador solar.';
    } else if (vientoMax > 15.0) {
      return 'Hay bastante viento (${vientoMax} km/h). Considera llevar una chaqueta ligera.';
    } else {
      return 'El clima se ve excelente para tu visita. ¡Disfruta!';
    }
  }

  // 🌤️ Convierte el código numérico de Open-Meteo (Weather Code) en texto descriptivo legible[cite: 4]
  String get descripcionClima {
    switch (weatherCode) {
      case 0:
        return 'Cielo despejado ☀️';
      case 1:
      case 2:
      case 3:
        return 'Parcialmente nublado ⛅';
      case 45:
      case 48:
        return 'Neblina 🌫️';
      case 51:
      case 53:
      case 55:
        return 'Llovizna 🌧️';
      case 61:
      case 63:
      case 65:
        return 'Lluvia 🌧️';
      case 71:
      case 73:
      case 75:
        return 'Nieve ❄️';
      case 95:
      case 96:
      case 99:
        return 'Tormenta eléctrica ⚡';
      default:
        return 'Condiciones variables ($weatherCode)';
    }
  }
}