import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class Farmacia {
  int id;
  int userId;
  String nomFarmacia;
  String? rfc;
  String? telefono;
  String? descripcion;
  int horarioEntrada;
  int horarioSalida;
  double promedio;

  Farmacia({
    required this.id,
    required this.userId,
    required this.nomFarmacia,
    this.rfc,
    this.telefono,
    this.descripcion,
    required this.horarioEntrada,
    required this.horarioSalida,
    required this.promedio,
  });

  static Future<List<Farmacia>> all() async {
    try {
      var url = Uri.http('localhost:8000', '/api/pharmacies'); 
      var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer 42|g2CRhU1BjuXHFOU2PENl1wetSWnMHj3dhxcDVPzae816f21e",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        List listado = jsonResponse['data'] ?? [];
        
        return listado.map((item) => Farmacia.fromJson(item)).toList();
      }
    } catch (e) {
      print('🔴 ERROR AL CARGAR FARMACIAS: $e');
    }
    return [];
  }

  factory Farmacia.fromJson(Map<String, dynamic> json) {
    return Farmacia(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nomFarmacia: json['nom_farmacia']?.toString() ?? 'Sin nombre',
      rfc: json['rfc']?.toString(),
      telefono: json['telefono']?.toString(),
      descripcion: json['descripcion']?.toString(),
      horarioEntrada: _parsearHora(json['horario_entrada']),
      horarioSalida: _parsearHora(json['horario_salida']),
      promedio: json['promedio']?.toDouble() ?? 0.0,
    );
  }

  static int _parsearHora(dynamic horaRaw) {
    if (horaRaw == null) return 0;
    String horaTexto = horaRaw.toString();
    if (horaTexto.isEmpty) return 0;
    try {
      List<String> partes = horaTexto.split(':');
      if (partes.isNotEmpty) {
        return int.parse(partes[0]);
      }
    } catch (e) {
      print("Error parseando hora farmacia: $horaTexto");
    }
    return 0;
  }
}