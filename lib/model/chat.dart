import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:buscadoc_mobile/utils/global.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> iniciarNotificacionesPush() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Pedimos permisos al celular
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken = await messaging.getToken();
      
      if (fcmToken != null) {
        debugPrint("FCM Token de este dispositivo: $fcmToken");
        await _guardarTokenEnLaravel(fcmToken);
      }
      
      messaging.onTokenRefresh.listen((newToken) {
        _guardarTokenEnLaravel(newToken);
      });
    }
  }

  static Future<void> _guardarTokenEnLaravel(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('token') ?? '';

    if (authToken.isEmpty) return;

    try {
      final url = Uri.parse('${Globals.webUrl}/api/usuarios/fcm-token');

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      );
      debugPrint("Token FCM guardado en Laravel exitosamente.");
    } catch (e) {
      debugPrint("Error guardando FCM token en Laravel: $e");
    }
  }

}