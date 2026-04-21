class Expediente {
  final int id;
  final String nombreCompleto;
  final String fechaNacimiento;
  final String genero;
  final String parentesco;
  final String? tipoSangre;
  final String? alergias;
  final String? padecimientos;
  final String? habitos;

  Expediente({
    required this.id,
    required this.nombreCompleto,
    required this.fechaNacimiento,
    required this.genero,
    required this.parentesco,
    this.tipoSangre,
    this.alergias,
    this.padecimientos,
    this.habitos,
  });

  factory Expediente.fromJson(Map<String, dynamic> json) {
    return Expediente(
      id: json['id'],
      nombreCompleto: json['nombre_completo'],
      fechaNacimiento: json['fecha_nacimiento'],
      genero: json['genero'],
      parentesco: json['parentesco'],
      tipoSangre: json['tipo_sangre'],
      alergias: json['alergias'],
      padecimientos: json['padecimientos_cronicos'],
      habitos: json['habitos_salud'],
    );
  }
}