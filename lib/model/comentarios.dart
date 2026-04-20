class Comentario {
  final int id;
  final String autor;
  final String contenido;
  final double calificacion;
  final String fecha;
  final String? foto;
  final List<dynamic> respuestas;

  Comentario({
    required this.id,
    required this.autor,
    required this.contenido,
    required this.calificacion,
    required this.fecha,
    required this.foto,
    required this.respuestas,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] ?? 0,
      autor: json['autor'] ?? 'Anónimo',
      foto: json['foto_autor'].toString(),
      contenido: json['contenido'] ?? '',
      calificacion: json['calificacion'] != null ? (json['calificacion'] as num).toDouble() : 0.0,
      fecha: json['fecha'] ?? '',
      respuestas: json['respuestas'] ?? [],
    );
  }
}