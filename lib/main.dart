import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/inicio_screen.dart';

void main() {
  runApp(const ExploraVerapazApp());
}

class ExploraVerapazApp extends StatelessWidget {
  const ExploraVerapazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explora Verapaz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Soporte para formato de fechas en español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'GT'),
        Locale('es', 'ES'),
      ],
      home: const InicioScreen(),
    );
  }
}