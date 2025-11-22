import 'package:flutter/material.dart';

class MiTema{
  static Color azulMarino = const Color.fromARGB(255, 0, 33, 61);
  static Color turquesaclaro = const Color.fromARGB(255, 135, 228, 219);
  static Color verdepetroleo = const Color.fromARGB(255, 10, 101, 118);
  static Color rojoescarlata = const Color.fromARGB(255, 230, 49, 43);
  static Color verdeazulado = const Color.fromARGB(255, 79, 161, 171);
  static Color azulgrisaceo = const Color.fromARGB(255, 186, 205, 209);
  static Color verdementa = const Color.fromARGB(255, 202, 240, 193);
  static Color azulavanda = const Color.fromARGB(255, 204, 219, 245);
  static Color negro = const Color.fromARGB(255, 0, 0, 0);
  static Color azulhielo = const Color.fromARGB(255, 222, 233, 242);
  static Color azulblanco = const Color.fromARGB(255, 235, 241, 245);
  static Color blanco = const Color.fromARGB(255, 255, 255, 255);

  static ThemeData temaApp(BuildContext context) {
    return ThemeData(
        snackBarTheme: _temasnack(),
        colorScheme: _esquemaColores(context), appBarTheme: _temaAppBar());
  }

  static ColorScheme _esquemaColores(BuildContext context) {
    return ColorScheme(
        brightness: MediaQuery.platformBrightnessOf(context),
        primary: azulMarino,
        onPrimary: Colors.white,
        secondary: verdementa,
        onSecondary: negro,
        error: Colors.red,
        onError: Colors.white,
        surface: azulblanco,
        onSurface: negro
      );
  }

  static AppBarTheme _temaAppBar() {
    return AppBarTheme(backgroundColor: azulMarino, foregroundColor: Colors.white);
  }

  static SnackBarThemeData _temasnack(){
    return SnackBarThemeData(
      backgroundColor: turquesaclaro,
      contentTextStyle: TextStyle(color: negro)
    );
  }
}
