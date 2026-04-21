import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class AgendarProvider {
  // 1. Obtener expedientes (para el dropdown)
  static Future<Map<String, dynamic>> getExpedientes() async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.get(
        Uri.parse('${Globals.webUrl}/api/mis-expedientes'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  // 2. Enviar la cita
  static Future<Map<String, dynamic>> agendarCita(int doctorId, Map<String, dynamic> data) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.post(
        Uri.parse('${Globals.webUrl}/api/doctores/$doctorId/agendar'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
        body: data,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}