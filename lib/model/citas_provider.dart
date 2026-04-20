import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class CitasProvider {
  static Future<Map<String, dynamic>> getCitas() async {
    String? token = await Usuario.obtenerToken();
    if (token == null) return {'success': false, 'message': 'No autenticado'};

    try {
      var response = await http.get(
        Uri.parse('${Globals.webUrl}/api/citas'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateStatus(int citaId, String estado) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.patch(
        Uri.parse('${Globals.webUrl}/api/citas/$citaId/status'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
        body: {'estado': estado},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> responderCambio(int citaId, String accion, {String? motivo}) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.post(
        Uri.parse('${Globals.webUrl}/api/citas/$citaId/responder-cambio'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
        body: {
          'accion': accion,
          if (motivo != null) 'motivo_rechazo': motivo
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> eliminarCita(int citaId) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.delete(
        Uri.parse('${Globals.webUrl}/api/citas/$citaId'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> getDisponibilidad(int doctorId, String fecha) async {
    try {
      var response = await http.get(
        Uri.parse('${Globals.webUrl}/api/disponibilidad/$doctorId?fecha=$fecha'),
        headers: {"Accept": "application/json"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'slots': [], 'mensaje': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> solicitarCambio(int citaId, String fecha, String hora, String motivo) async {
    String? token = await Usuario.obtenerToken();
    try {
      var response = await http.post(
        Uri.parse('${Globals.webUrl}/api/citas/$citaId/solicitar-cambio'),
        headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
        body: {
          'nueva_fecha': fecha,
          'nueva_hora': hora,
          'motivo': motivo,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}