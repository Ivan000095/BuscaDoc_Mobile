import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buscadoc_mobile/utils/global.dart';

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
        // Ignorar si falla
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
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        String id = jsonResponse['data']['user']['id'].toString();
        String tokenGuardado = jsonResponse['data']['token'];
        String rolGuardado = jsonResponse['data']['user']['role'] ?? 'paciente';
        String nombreGuardado = jsonResponse['data']['user']['name'] ?? 'Usuario';
        String fotoGuardada = jsonResponse['data']['user']['foto'] ?? '';
        String email = jsonResponse['data']['user']['email'] ?? '';

        await prefs.setString('id', id);
        await prefs.setString('token', tokenGuardado);
        await prefs.setString('role', rolGuardado);
        await prefs.setString('userName', nombreGuardado);
        await prefs.setString('userFoto', fotoGuardada);
        await prefs.setString('userEmail', email);

        return {
          'success': true,
          'token': tokenGuardado,
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
        print(e);
      return {
        'success': false,
        'message': 'Error de conexión. Revisa que el servidor esté encendido.',
      };
    }
  }

  static Future<String?> obtenerToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> dashboard(String token) async {
    try {
      print("TOKEN ENVIADO A LARAVEL: $token");
      var url = Uri.parse('http://127.0.0.1:8000/api/home-dashboard');
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {
          'success': true,
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Error al obtener los datos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión con el servidor. Revisa tu internet.',
      };
    }
  }

  static Future<Map<String, dynamic>> show(String token, int id) async {
    try {
      print("TOKEN ENVIADO A LARAVEL: $token");
      var url = Uri.parse('http://127.0.0.1:8000/api/user/$id');
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {
          'success': true,
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Error al obtener los datos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión con el servidor. Revisa tu internet.',
      };
    }
  }

  static Future<Map<String, dynamic>> update(String token, int id, Map<String, dynamic> datosActualizados) async {
    try {
      var url = Uri.parse('${Globals.webUrl}/api/user/$id');
      print(url);
      
      var response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(datosActualizados),
      );

      var jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Perfil actualizado correctamente',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Error al actualizar los datos',
        };
      }
    } catch (e) {
      print("🚨 ERROR CRÍTICO AL ACTUALIZAR: $e");
      return {
        'success': false,
        'message': 'Error de conexión con el servidor. Revisa tu internet.',
      };
    }
  }
}
