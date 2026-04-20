import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class Paciente {
  int id;
  int userId;
  String nombre; // Relación user.name
  String email;  // Relación user.email
  String tipoSangre;
  String? alergias;
  String? cirugias;
  String? padecimientos;
  String? habitos;
  String? contactoEmergencia;

  Paciente({
    required this.id,
    required this.userId,
    required this.nombre,
    required this.email,
    required this.tipoSangre,
    this.alergias,
    this.cirugias,
    this.padecimientos,
    this.habitos,
    this.contactoEmergencia,
  });

  
  static Future<Paciente?> getProfile() async {
    try {
      var url = Uri.parse('http://localhost:8000/api/patient/profile'); 
      var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer 42|g2CRhU1BjuXHFOU2PENl1wetSWnMHj3dhxcDVPzae816f21e",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        var data = jsonResponse['data'] ?? jsonResponse;
        return Paciente.fromJson(data);
      }
    } catch (e) {
      print('🔴 ERROR AL OBTENER PACIENTE: $e');
    }
    return null;
  }

  
  Future<bool> update() async {
    try {
      var url = Uri.parse('http://localhost:8000/api/patient/update/$id');
      var response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer 42|g2CRhU1BjuXHFOU2PENl1wetSWnMHj3dhxcDVPzae816f21e",
        },
        body: convert.jsonEncode({
          'tipo_sangre': tipoSangre,
          'alergias': alergias,
          'cirugias': cirugias,
          'padecimientos': padecimientos,
          'habitos': habitos,
          'contacto_emergencia': contactoEmergencia,
          
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Paciente actualizado");
        return true;
      } else {
        print("❌ Error al actualizar: ${response.body}");
      }
    } catch (e) {
      print('🔴 ERROR AL ACTUALIZAR: $e');
    }
    return false;
  }

  factory Paciente.fromJson(Map<String, dynamic> json) {
    
    return Paciente(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nombre: json['user']?['name']?.toString() ?? 'Sin nombre',
      email: json['user']?['email']?.toString() ?? 'Sin email',
      tipoSangre: json['tipo_sangre']?.toString() ?? '',
      alergias: json['alergias']?.toString(),
      cirugias: json['cirugias']?.toString(),
      padecimientos: json['padecimientos']?.toString(),
      habitos: json['habitos']?.toString(),
      contactoEmergencia: json['contacto_emergencia']?.toString(),
    );
  }
}