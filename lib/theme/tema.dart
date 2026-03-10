import 'package:flutter/material.dart';

class MiTema {
  static Color gris = const Color(0xFFF8F8F8);
  static Color azulOscuro = const Color(0xFF00213D);
  static Color blanco = const Color(0xFFFFFFFF);
  static Color negro = const Color(0xFF000000);
  static Color azul = const Color.fromARGB(106, 14, 64, 109);

  static ThemeData temaApp(BuildContext context) {
    return ThemeData(
        snackBarTheme: _temaSnack(),
        colorScheme: _esquemaColores(context),
        appBarTheme: _temaAppBar(),
        scaffoldBackgroundColor: gris,
        useMaterial3: true, // Recomendado para versiones modernas
    );
  }

  static ColorScheme _esquemaColores(BuildContext context) {
    return ColorScheme(
        brightness: Brightness.light, // Ajustado para evitar parpadeos
        primary: azulOscuro,
        onPrimary: blanco,
        secondary: blanco,
        onSecondary: azulOscuro,
        error: Colors.red,
        onError: Colors.white,
        surface: blanco,
        onSurface: azulOscuro);
  }

  static AppBarTheme _temaAppBar() => AppBarTheme(backgroundColor: azulOscuro, foregroundColor: blanco);
  static SnackBarThemeData _temaSnack() => SnackBarThemeData(backgroundColor: gris, contentTextStyle: TextStyle(color: azulOscuro));
}