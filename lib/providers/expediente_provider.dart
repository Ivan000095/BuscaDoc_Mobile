import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class ExpedientesProvider {
  // Obtener todos los expedientes del usuario
  static Future<Map<String, dynamic>> getExpedientes() async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.get(
        Uri.parse('${Globals.webUrl}/api/expedientes'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> crearExpediente(Map<String, dynamic> data) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.post(
        Uri.parse('${Globals.webUrl}/api/expedientes'),
        headers: {
          "Accept": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: data,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> getExpedienteDetalle(int id) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.get(
        Uri.parse('${Globals.webUrl}/api/expedientes/$id'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // Actualizar un expediente
  static Future<Map<String, dynamic>> actualizarExpediente(int id, Map<String, dynamic> data) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.put(
        Uri.parse('${Globals.webUrl}/api/expedientes/$id'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
        body: data,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}