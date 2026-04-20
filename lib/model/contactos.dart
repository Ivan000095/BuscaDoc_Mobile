import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class ContactoChat {
  final String id;
  final String nombre;
  final String rol;
  final String especialidad;
  final String fotoUrl;
  final int mensajesSinLeer;
  final bool enLinea;

  ContactoChat({
    required this.id,
    required this.nombre,
    required this.rol,
    this.especialidad = '',
    required this.fotoUrl,
    this.mensajesSinLeer = 0,
    this.enLinea = false,
  });

  factory ContactoChat.fromJson(Map<String, dynamic> json) {
    return ContactoChat(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      rol: json['rol'] ?? 'paciente',
      especialidad: json['especialidad'] ?? '',
      fotoUrl: json['fotoUrl'] ?? 'https://ui-avatars.com/api/?name=Usuario',
      mensajesSinLeer: json['mensajesSinLeer'] ?? 0,
      enLinea: json['enLinea'] ?? false,
    );
  }
  static Future<List<ContactoChat>> obtenerContactos(String tokenUsuario) async {
      final url = Uri.parse('${Globals.webUrl}/api/mensajes/contactos'); 
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $tokenUsuario', 
          },
        );

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          return data.map((json) => ContactoChat.fromJson(json)).toList();
        } else {
          debugPrint('Error de servidor: ${response.statusCode}');
          return []; 
        }
      } catch (e) {
        debugPrint('Error de conexión al obtener contactos: $e');
        return []; 
      }
    }
}