import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

  // ─────────────────────────────────────────────────────
  // 🔹 REGISTRAR (sin cambios - ya funciona)
  // ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> registrar(
    Map<String, dynamic> datos, {
    File? fotoPerfil,
  }) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/auth/register');
      final request = http.MultipartRequest('POST', url)
        ..headers['Accept'] = 'application/json';

      datos.forEach((key, value) {
        if (value == null) return;
        
        if (key == 'citas') {
          if (value is bool) {
            request.fields[key] = value ? '1' : '0';
          } else if (value is String) {
            request.fields[key] = (value.toLowerCase() == 'true' || value == '1') ? '1' : '0';
          }
        }
        else if (key == 'especialidades' && value is List) {
          for (var i = 0; i < value.length; i++) {
            request.fields['especialidades[$i]'] = value[i].toString();
          }
        }
        else if (key == 'horarios' && value is List) {
          for (var i = 0; i < value.length; i++) {
            final horario = value[i];
            if (horario is Map) {
              request.fields['horarios[$i][dia]'] = horario['dia'].toString();
              request.fields['horarios[$i][inicio]'] = horario['inicio'].toString();
              request.fields['horarios[$i][fin]'] = horario['fin'].toString();
            }
          }
        }
        else {
          request.fields[key] = value.toString();
        }
      });

      if (fotoPerfil != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', fotoPerfil.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        final userData = jsonResponse['data']['user'];
        final token = jsonResponse['data']['token'];
        await _guardarSesion(userData, token);
        Globals.fotoPerfilActual = userData['foto'];
        
        return {
          'success': true,
          'token': token,
          'user': userData,
        };
      }

      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Error al registrar',
        'errors': jsonResponse['errors'],
      };
    } catch (e) {
      return _errorConexion(e);
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 LOGIN (sin cambios)
  // ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/auth/login');
      final deviceName = Platform.isAndroid ? 'Android_Device' : 'iOS_Device';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final userData = jsonResponse['data']['user'];
        await _guardarSesion(userData, jsonResponse['data']['token']);
        Globals.fotoPerfilActual = userData['foto'];
        
        return {
          'success': true,
          'token': jsonResponse['data']['token'],
          'user': userData,
        };
      }

      return {
        'success': false,
        'message': _obtenerMensajeError(jsonResponse),
      };
    } catch (e) {
      return _errorConexion(e);
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 LOGOUT (sin cambios)
  // ─────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final token = await obtenerToken();
      if (token != null) {
        final url = Uri.parse('${Globals.webUrl}/api/auth/logout');
        await http.post(
          url,
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {
    } finally {
      await _limpiarSesion();
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 SHOW USER (sin cambios)
  // ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> show(String token, int id) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/user/$id');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {'success': true, 'data': jsonResponse['data']};
      }

      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Error al cargar perfil',
      };
    } catch (e) {
      return _errorConexion(e);
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 UPDATE PROFILE - CENTRALIZADO Y OPTIMIZADO
  // ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required int userId,
    required String role,  // 'paciente' o 'doctor'
    
    // 🔹 Campos base (comunes)
    String? name,
    String? email,
    String? fNacimiento,
    double? latitud,
    double? longitud,
    File? foto,
    
    // 🔹 Campos sensibles (requieren current_password)
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
    
    // 🔹 Campos específicos de DOCTOR
    String? cedula,
    num? costo,
    int? duracionCita,
    bool? citas,
    String? descripcionDoc,
    String? idiomas,
    List<int>? especialidades,
    List<Map<String, dynamic>>? horarios,
  }) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/auth/profile');
      
      // 🔹 Construir mapa de datos a enviar
      final datos = <String, dynamic>{};
      
      // Campos base (solo agregar si no son null)
      if (name != null) datos['name'] = name;
      if (email != null) datos['email'] = email;
      if (fNacimiento != null) datos['f_nacimiento'] = fNacimiento;
      if (latitud != null) datos['latitud'] = latitud.toString();
      if (longitud != null) datos['longitud'] = longitud.toString();
      if (currentPassword != null) datos['current_password'] = currentPassword;
      if (password != null) datos['password'] = password;
      if (passwordConfirmation != null) datos['password_confirmation'] = passwordConfirmation;
      
      // 🔹 Campos de DOCTOR (solo si role es 'doctor')
      if (role == 'doctor') {
        if (cedula != null) datos['cedula'] = cedula;
        if (costo != null) datos['costo'] = costo.toString();
        if (duracionCita != null) datos['duracion_cita'] = duracionCita.toString();
        if (citas != null) datos['citas'] = citas;  // bool → backend lo convierte
        if (descripcionDoc != null) datos['descripcion_doc'] = descripcionDoc;
        if (idiomas != null) datos['idiomas'] = idiomas;
        if (especialidades != null) datos['especialidades'] = especialidades;
        if (horarios != null) datos['horarios'] = horarios;
      }
      
      // Filtrar nulls
      datos.removeWhere((key, value) => value == null);
      
      // 🔹 Enviar request
      if (foto != null) {
        // Multipart para actualización con foto
        final request = http.MultipartRequest('POST', url)
          ..headers['Accept'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['_method'] = 'PUT';
        
        // Procesar campos según tipo
        datos.forEach((key, value) {
          if (value == null) return;
          
          // Boolean citas → "1" o "0" para multipart
          if (key == 'citas' && value is bool) {
            request.fields[key] = value ? '1' : '0';
          }
          // Array especialidades
          else if (key == 'especialidades' && value is List) {
            for (var i = 0; i < value.length; i++) {
              request.fields['especialidades[$i]'] = value[i].toString();
            }
          }
          // Array horarios (multidimensional)
          else if (key == 'horarios' && value is List) {
            for (var i = 0; i < value.length; i++) {
              final h = value[i];
              if (h is Map) {
                request.fields['horarios[$i][dia]'] = h['dia'].toString();
                request.fields['horarios[$i][inicio]'] = h['inicio'].toString();
                request.fields['horarios[$i][fin]'] = h['fin'].toString();
              }
            }
          }
          // Campos normales
          else {
            request.fields[key] = value.toString();
          }
        });
        
        // Agregar foto
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final jsonResponse = jsonDecode(response.body);
        
        return _procesarRespuesta(response.statusCode, jsonResponse, 'actualizar');
        
      } else {
        // JSON normal sin foto
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(datos),
        );
        
        final jsonResponse = jsonDecode(response.body);
        return _procesarRespuesta(response.statusCode, jsonResponse, 'actualizar');
      }
      
    } catch (e) {
      print('❌ Error en updateProfile: $e');
      return _errorConexion(e);
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 DELETE ACCOUNT (sin cambios)
  // ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteAccount(String token, int id) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/user/$id');
      final response = await http.delete(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      final jsonResponse = jsonDecode(response.body);
      return _procesarRespuesta(response.statusCode, jsonResponse, 'eliminar');
    } catch (e) {
      return _errorConexion(e);
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 DASHBOARD (sin cambios)
  // ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> dashboard(String token) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/home-dashboard');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {'success': true, 'data': jsonResponse['data']};
      }

      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Error al cargar dashboard',
      };
    } catch (e) {
      return _errorConexion(e);
    }
  }

  // ─────────────────────────────────────────────────────
  // 🔹 MÉTODOS DE SESIÓN (sin cambios)
  // ─────────────────────────────────────────────────────
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> obtenerDatosSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('id') ?? '',
      'token': prefs.getString('token') ?? '',
      'role': prefs.getString('role') ?? '',
      'name': prefs.getString('userName') ?? '',
      'foto': prefs.getString('userFoto') ?? '',
      'email': prefs.getString('userEmail') ?? '',
    };
  }

  static Future<void> _guardarSesion(Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', user['id']?.toString() ?? '');
    await prefs.setString('token', token);
    await prefs.setString('role', user['role'] ?? 'paciente');
    await prefs.setString('userName', user['name'] ?? 'Usuario');
    await prefs.setString('userFoto', user['foto'] ?? '');
    await prefs.setString('userEmail', user['email'] ?? '');
  }

  static Future<void> _limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─────────────────────────────────────────────────────
  // 🔹 HELPERS (sin cambios)
  // ─────────────────────────────────────────────────────
  static String _obtenerMensajeError(Map<String, dynamic> response) {
    if (response['errors'] != null) {
      final errors = response['errors'] as Map;
      if (errors['email'] != null) return errors['email'][0];
      if (errors['password'] != null) return errors['password'][0];
    }
    return response['message'] ?? 'Credenciales incorrectas';
  }

  static Map<String, dynamic> _procesarRespuesta(
    int statusCode,
    Map<String, dynamic> json,
    String accion,
  ) {
    if (statusCode == 200 && json['success'] == true) {
      return {
        'success': true,
        'message': json['message'] ?? 'Operación exitosa',
      };
    }
    return {
      'success': false,
      'message': json['message'] ?? 'Error al $accion',
      'errors': json['errors'],
    };
  }

  static Map<String, dynamic> _errorConexion(dynamic error) {
    return {
      'success': false,
      'message': 'Error de conexión. Verifica tu internet o que el servidor esté activo.',
      'debug': error.toString(),
    };
  }

  static Future<void> inicializarFotoGlobal() async {
    final prefs = await SharedPreferences.getInstance();
    String? foto = prefs.getString('userFoto');
    Globals.fotoPerfilActual = (foto != null && foto.isNotEmpty) ? foto : null;
  }
}