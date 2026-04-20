class Reply {
  final int id;
  final int comentarioId;
  final int idRespondedor;
  final String contenido;
  final DateTime createdAt;
  final Respondedor? respondedor;

  Reply({
    required this.id,
    required this.comentarioId,
    required this.idRespondedor,
    required this.contenido,
    required this.createdAt,
    this.respondedor,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] ?? 0,
      comentarioId: json['comentario_id'] ?? 0,
      idRespondedor: json['id_respondedor'] ?? 0,
      contenido: json['contenido'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      respondedor: json['respondedor'] != null
          ? Respondedor.fromJson(json['respondedor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comentario_id': comentarioId,
      'id_respondedor': idRespondedor,
      'contenido': contenido,
      'created_at': createdAt.toIso8601String(),
      'respondedor': respondedor?.toJson(),
    };
  }
}

class Respondedor {
  final int id;
  final String name;
  final String? foto;
  final String role;

  Respondedor({
    required this.id,
    required this.name,
    this.foto,
    required this.role,
  });

  factory Respondedor.fromJson(Map<String, dynamic> json) {
    return Respondedor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      foto: json['foto'],
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'foto': foto,
      'role': role,
    };
  }
}