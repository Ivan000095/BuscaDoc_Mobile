class Farmacia {
  final int id;
  final String nombre;
  final String descripcion;
  final String horarioEntrada;
  final String horarioSalida;
  final String telefono;
  final String? rfc;
  final double latitud;
  final double longitud;
  final String? imagen;
  final String? responsableNombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Farmacia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.horarioEntrada,
    required this.horarioSalida,
    required this.telefono,
    required this.rfc,
    required this.latitud,
    required this.longitud,
    this.imagen,
    this.responsableNombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farmacia.fromJson(Map<String, dynamic> json) {
    final ubicacion = json['ubicacion'] ?? {};
    final responsable = json['responsable'] ?? {};

    return Farmacia(
      id: json['id'] ?? 0,
      nombre: json['nom_farmacia'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? '',
      horarioEntrada: _formatearHora(json['horario_entrada']),
      horarioSalida: _formatearHora(json['horario_salida']),
      telefono: json['telefono']?? 'No registrado',
      rfc: json['rfc'] ?? '',
      latitud: _parseDouble(ubicacion['lat']),
      longitud: _parseDouble(ubicacion['lng']),
      
      imagen: responsable['avatar'],
      responsableNombre: responsable['nombre_completo'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static String _formatearHora(dynamic hora) {
    if (hora == null) return '--:--';
    if (hora.toString().contains(':')) {
      final partes = hora.toString().split(':');
      if (partes.length >= 2) {
        return '${partes[0]}:${partes[1]}';
      }
    }
    return hora.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_farmacia': nombre,
      'descripcion': descripcion,
      'horario_entrada': horarioEntrada,
      'horario_salida': horarioSalida,
      'telefono' : telefono,
      'rfc' : rfc,
      'ubicacion': {
        'lat': latitud,
        'lng': longitud,
      },
      'responsable': {
        'avatar': imagen,
        'nombre_completo': responsableNombre,
      },
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}