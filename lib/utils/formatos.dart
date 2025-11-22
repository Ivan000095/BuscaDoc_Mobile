class Formatos {
  static String fecha(DateTime f) {
    List meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${f.day} de ${meses[f.month - 1]} del ${f.year}';
  }

  static int comparaFechaHoy(DateTime f) {
    DateTime hoy = DateTime.now();
    if (hoy.year == f.year && hoy.month == f.month && hoy.day == f.day) {
      return 0;
    } else if (hoy.year > f.year ||
        (hoy.year == f.year && hoy.month > f.month) ||
        (hoy.year == f.year && hoy.month == f.month && hoy.day > f.day)) {
      // ignore: curly_braces_in_flow_control_structures
      return 1;
    } else {
      // ignore: curly_braces_in_flow_control_structures
      return -1;
    }
  }

  static int edad(DateTime f) {
    DateTime hoy = DateTime.now();
    int edad = hoy.year - f.year;
    return edad;
  }

  static String horario(int h) {
    String horario = h < 12 ? '$h:00 AM' : (h > 12 ? '${h-12}:00 PM' : '12:00 PM');
    return horario;
  }

  static bool compararhoras(int he, int hs) {
    DateTime ahora = DateTime.now();
    bool valor = ahora.hour > he && ahora.hour < hs ? true : false;
    return valor;
  }
}
