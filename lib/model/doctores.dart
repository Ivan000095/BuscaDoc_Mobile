// ignore_for_file: avoid_print

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:buscadoc_mobile/utils/global.dart';

class Doctores {
  final int id;
  final int idUsuario;
  final String especialidad;
  final String nombre;
  final String descripcion;
  final DateTime fecha;
  final String image;
  final String telefono;
  final String idiomas;
  final String cedula;
  final String rol;
  final String horarioentrada;
  final String horariosalida;
  final num costos;
  final double? promedio;
  final String? latitud;
  final String? longitud;
  final bool? citas;
  final List<dynamic> disponibilidades;

  Doctores({
    required this.id,
    required this.idUsuario,
    required this.especialidad,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.image,
    required this.telefono,
    required this.horarioentrada,
    required this.horariosalida,
    required this.idiomas,
    required this.cedula,
    required this.rol,
    required this.costos,
    required this.promedio,
    required this.disponibilidades,
    this.latitud,
    this.longitud,
    this.citas,
  });

  static Future<List<Doctores>> all({
    String? search,
    int? especialidadId,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    try {

      final uri = Uri.parse('${Globals.webUrl}/api/doctors').replace(
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (especialidadId != null) 'especialidad_id': especialidadId.toString(),
          'sort_by': sortBy,
          'sort_direction': sortDirection,
          'page': page.toString(),
          'per_page': perPage.clamp(1, 100).toString(),
          },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        final List listado = jsonResponse['data'] ?? [];
        
        print('Doctores recibidos: ${listado.length}');
        
        return listado.map((element) => Doctores.fromJson(element)).toList();
      } else {
        print('Error del servidor: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('ERROR AL CARGAR DOCTORES: $e');
    }
    return [];
  }

  static Future<Doctores?> getById(int id) async {
    try {
      final url = Uri.parse('${Globals.webUrl}/api/doctors/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return Doctores.fromJson(jsonResponse['data']);
        }
      } else {
        print('❌ Error al obtener doctor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    return null;
  }

  static String _obtenerEntrada(Map<String, dynamic> json) {
    if (json['horarioentrada'] != null && json['horarioentrada'].toString().isNotEmpty) {
      return json['horarioentrada'].toString();
    }
    
    var disponibilidades = json['disponibilidades'] ?? json['disponibilidad'] ?? [];
    if (disponibilidades is List && disponibilidades.isNotEmpty) {
      int hoyDart = DateTime.now().weekday;
      int hoyLaravel = hoyDart == 7 ? 0 : hoyDart; 
      
      for (var disp in disponibilidades) {
        if (disp['dia_semana'] == hoyLaravel) {
          String inicio = disp['hora_inicio'].toString();
          return inicio.length >= 5 ? inicio.substring(0, 5) : inicio; // Retorna "09:00"
        }
      }
    }
    return 'Descanso';
  }

  static String _obtenerSalida(Map<String, dynamic> json) {
    if (json['horariosalida'] != null && json['horariosalida'].toString().isNotEmpty) {
      return json['horariosalida'].toString();
    }
    
    var disponibilidades = json['disponibilidades'] ?? json['disponibilidad'] ?? [];
    if (disponibilidades is List && disponibilidades.isNotEmpty) {
      int hoyDart = DateTime.now().weekday;
      int hoyLaravel = hoyDart == 7 ? 0 : hoyDart; 
      
      for (var disp in disponibilidades) {
        if (disp['dia_semana'] == hoyLaravel) {
          String fin = disp['hora_fin'].toString();
          return fin.length >= 5 ? fin.substring(0, 5) : fin;
        }
      }
    }
    return '';
  }

  factory Doctores.fromJson(Map<String, dynamic> json) {
    var datosDisponibilidad = json['disponibilidades'] ?? json['disponibilidad'] ?? [];
    
    return Doctores(
      id: json['id'] ?? 0,
      idUsuario: json['user_id'] ?? json['user']?['id'] ?? 0,
      especialidad: _obtenerEspecialidad(json),
      nombre: json['user']?['name']?.toString() ?? json['name']?.toString() ?? 'Sin nombre',
      descripcion: json['descripcion']?.toString() ?? '',
      fecha: _parsearFecha(json['fecha']),
      image: _fixImageUrl(json['user']?['foto'] ?? json['image']),
      telefono: json['telefono']?.toString() ?? 'Sin teléfono',
      
      horarioentrada: _obtenerEntrada(json),
      horariosalida: _obtenerSalida(json),
      
      idiomas: json['idioma']?.toString() ?? '',
      cedula: json['cedula']?.toString() ?? '',
      rol: json['role']?.toString() ?? 'doctor',
      costos: _parsearCosto(json['costos']),
      promedio: (json['promedio'] as num?)?.toDouble() ?? 0.0,
      latitud: json['latitud']?.toString() ?? json['user']?['latitud']?.toString(),
      longitud: json['longitud']?.toString() ?? json['user']?['longitud']?.toString(),
      citas: json['citas'] as bool? ?? false, // <-- Cuidado con los booleanos nulos
      disponibilidades: datosDisponibilidad is List ? datosDisponibilidad : [],
    );
  }


  static String _obtenerEspecialidad(Map<String, dynamic> json) {
    if (json['especialidades'] is List &&
        (json['especialidades'] as List).isNotEmpty) {
      final primera = (json['especialidades'] as List).first;
      if (primera is Map && primera['nombre'] != null) {
        return primera['nombre'].toString();
      }
    }
    if (json['especialidad'] != null) {
      return json['especialidad'].toString();
    }
    return 'Sin especialidad';
  }

  static String _fixImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/150?text=Sin+Foto';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return '${Globals.webUrl}/storage/$path';
  }

  static DateTime _parsearFecha(dynamic fechaRaw) {
    if (fechaRaw == null) return DateTime.now();
    if (fechaRaw is DateTime) return fechaRaw;
    
    final parsed = DateTime.tryParse(fechaRaw.toString());
    return parsed ?? DateTime.now();
  }

  static int _parsearHora(dynamic horaRaw) {
    if (horaRaw == null) return 0;
    final horaTexto = horaRaw.toString();
    if (horaTexto.isEmpty) return 0;
    
    try {
      final partes = horaTexto.split(':');
      if (partes.isNotEmpty) {
        return int.tryParse(partes[0]) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  static num _parsearCosto(dynamic costoRaw) {
    if (costoRaw == null) return 0;
    
    final costoString = costoRaw.toString()
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');
    
    return num.tryParse(costoString) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': idUsuario,
      'name': nombre,
      'especialidad': especialidad,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'image': image,
      'telefono': telefono,
      'horarioentrada': '$horarioentrada:00',
      'horariosalida': '$horariosalida:00',
      'idioma': idiomas,
      'cedula': cedula,
      'role': rol,
      'costos': costos.toString(),
      'promedio': promedio,
      'latitud': latitud,
      'longitud': longitud,
      'citas': citas,
    };
  }

  @override
  String toString() {
    return 'Doctores(id: $id, nombre: $nombre, especialidad: $especialidad, promedio: $promedio)';
  }
}