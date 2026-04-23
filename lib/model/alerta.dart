class Alerta {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo; // 'mensaje' o 'cita'
  final int? referenciaId;
  final bool leido;
  final DateTime createdAt;

  Alerta({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.referenciaId,
    required this.leido,
    required this.createdAt,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      tipo: json['tipo'],
      referenciaId: json['referencia_id'],
      leido: json['leido'] == 1 || json['leido'] == true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}