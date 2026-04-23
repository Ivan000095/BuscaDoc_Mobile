import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buscadoc_mobile/model/alerta.dart';
import 'package:buscadoc_mobile/utils/global.dart'; // Agregamos tus globales

class AlertaService {
  final String baseUrl = "${Globals.webUrl}/api";

  Future<List<Alerta>> getAlertas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alertas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((i) => Alerta.fromJson(i)).toList();
    } else {
      // AQUÍ ESTÁ LA MAGIA PARA DEBUGGEAR
      print('❌ ERROR STATUS CODE: ${response.statusCode}');
      print('❌ ERROR BODY: ${response.body}');
      throw Exception('El servidor respondió con error ${response.statusCode}');
    }
  }

  Future<void> marcarLeida(String token, int id) async {
    await http.post(
      Uri.parse('$baseUrl/alertas/$id/leer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<void> marcarTodasLeidas(String token) async {
  await http.post(
    Uri.parse('$baseUrl/alertas/leer-todas'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );
}
}