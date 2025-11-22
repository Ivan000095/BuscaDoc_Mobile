class Entrega {
  int id;
  int numero;
  DateTime fecha;
  String descripcion;

  Entrega(
      {required this.id,
      required this.numero,
      required this.fecha,
      required this.descripcion});

  static List<Entrega> all() {
    Entrega e1 = Entrega(
        id: 1,
        numero: 1,
        fecha: DateTime(2025, 9, 25),
        descripcion: 'Capítulo I');

    Entrega e2 = Entrega(
        id: 2,
        numero: 2,
        fecha: DateTime(2025, 10, 10),
        descripcion: 'Capítulo II.1, II.2 y II.3');

    Entrega e3 = Entrega(
        id: 3,
        numero: 3,
        fecha: DateTime(2025, 11, 17),
        descripcion: 'Capítulo III');

    Entrega e4 = Entrega(
        id: 4,
        numero: 4,
        fecha: DateTime(2025, 12, 8),
        descripcion: 'Capítulo IV');

    return [e1, e2, e3, e4];
  }
}
