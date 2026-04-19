import 'package:buscadoc_mobile/model/reply.dart';

class Comment {
  final int id;
  final int idAutor;
  final int idDestinatario;
  final String tipo;
  final int? calificacion;
  final String contenido;
  final DateTime createdAt;
  final Autor? autor;
  final List<Reply> respuestas;

  Comment({
    required this.id,
    required this.idAutor,
    required this.idDestinatario,
    required this.tipo,
    this.calificacion,
    required this.contenido,
    required this.createdAt,
    this.autor,
    List<Reply>? respuestas,
  }) : respuestas = respuestas ?? [];

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      idAutor: json['id_autor'] ?? 0,
      idDestinatario: json['id_destinatario'] ?? 0,
      tipo: json['tipo'] ?? '',
      calificacion: json['calificacion'],
      contenido: json['contenido'] ?? '',
      createdAt: _parseDate(json['created_at']),
      autor: json['autor'] != null ? Autor.fromJson(json['autor']) : null,
      respuestas: json['respuestas'] != null
          ? (json['respuestas'] as List)
              .map((r) => Reply.fromJson(r))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_autor': idAutor,
      'id_destinatario': idDestinatario,
      'tipo': tipo,
      'calificacion': calificacion,
      'contenido': contenido,
      'created_at': createdAt.toIso8601String(),
      'autor': autor?.toJson(),
      'respuestas': respuestas.map((r) => r.toJson()).toList(),
    };
  }

  static DateTime _parseDate(dynamic dateRaw) {
    if (dateRaw == null) return DateTime.now();
    if (dateRaw is DateTime) return dateRaw;
    
    final parsed = DateTime.tryParse(dateRaw.toString());
    return parsed ?? DateTime.now();
  }
}

class Autor {
  final int id;
  final String name;
  final String? foto;

  Autor({
    required this.id,
    required this.name,
    this.foto,
  });

  factory Autor.fromJson(Map<String, dynamic> json) {
    return Autor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'foto': foto,
    };
  }
}