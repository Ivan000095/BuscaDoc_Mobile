import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String? token;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.token,
  });

  static Future<Map<String, dynamic>> registrar(Map<String, dynamic> datosRegistro) async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/api/auth/register');
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(datosRegistro),
      );

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print(jsonResponse);
        return {
          'success': true,
          'token': jsonResponse['data']['token'],
          'user': jsonResponse['data']['user'],
        };
      } else {
        print(jsonResponse['message']);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Error desconocido al registrar.',
          'errores': jsonResponse['errors']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión con el servidor. Revisa tu internet.',
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/api/auth/login'); 
      String deviceName = "MobileApp_Unknown";
      try {
        deviceName = Platform.isAndroid ? "Android_Device" : "iOS_Device";
      } catch (e) {
        // Ignorar si falla la detección de plataforma
      }

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "device_name": deviceName,
        }),
      );

      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {
          'success': true,
          'token': jsonResponse['data']['token'],
          'user': jsonResponse['data']['user'], 
        };
      } else {
        String errorMsg = "Credenciales incorrectas";
        
        if (jsonResponse['errors'] != null && jsonResponse['errors']['email'] != null) {
          errorMsg = jsonResponse['errors']['email'][0];
        } else if (jsonResponse['message'] != null) {
          errorMsg = jsonResponse['message'];
        }
        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Revisa que el servidor esté encendido.',
      };
    }
  }

}
