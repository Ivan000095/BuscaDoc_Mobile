class Paciente {
  final int id;
  final String nombre; // Viene de user.name
  final String email;  // Viene de user.email
  final String? tipoSangre;
  final String? alergias;
  final String? padecimientos;

  Paciente({
    required this.id,
    required this.nombre,
    required this.email,
    this.tipoSangre,
    this.alergias,
    this.padecimientos,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      nombre: json['user']['name'], // Acceso anidado según tu controlador
      email: json['user']['email'],
      tipoSangre: json['tipo_sangre'],
      alergias: json['alergias'],
      padecimientos: json['padecimientos'],
    );
  }
}