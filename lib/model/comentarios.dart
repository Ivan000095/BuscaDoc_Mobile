class Comentario {
  int id;
  String contenido;
  String foto;

  Comentario(
      {required this.id,
      required this.contenido,
      required this.foto,
      });

  static List<Comentario> all() {
    Comentario e1 = Comentario(
        id: 1,
        contenido: 'Me gustó mucho el servicio',
        foto: 'assets/john.webp',
    );
    Comentario e2 = Comentario(
        id: 2,
        contenido: 'Pésimo',
        foto: 'assets/jesus.jpg',
    );
    Comentario e3 = Comentario(
        id: 3,
        contenido: 'Superrrr',
        foto: 'assets/jesus.jpg',
    );
    Comentario e4 = Comentario(
        id: 4,
        contenido: 'Muy terrible',
        foto: 'assets/jesus.jpg',
    );
    return [e1, e2, e3, e4];
  }
}
