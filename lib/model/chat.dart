import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:buscadoc_mobile/utils/global.dart'; 

class Mensaje {
  final String idRemitente;
  final String contenido;
  final String createdAt;
  final bool isMine;

  Mensaje({
    required this.idRemitente,
    required this.contenido,
    required this.createdAt,
    required this.isMine,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json, String miId) {
    return Mensaje(
      idRemitente: json['id_remitente'].toString(),
      contenido: json['contenido'] ?? '',
      createdAt: json['created_at'] ?? '',
      isMine: json['id_remitente'].toString() == miId,
    );
  }

  static Future<List<Mensaje>> obtenerMensajes(String token, String miId, String idContacto) async {
    final url = Uri.parse('${Globals.webUrl}/api/mensajes/$idContacto');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((j) => Mensaje.fromJson(j, miId)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error obteniendo mensajes: $e');
      return [];
    }
  }

  static Future<bool> enviarMensaje(String token, String idContacto, String contenido) async {
    final url = Uri.parse('${Globals.webUrl}/api/mensajes');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_destinatario': idContacto,
          'contenido': contenido,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error enviando mensaje: $e');
      return false;
    }
  }
}