// ignore_for_file: avoid_print

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:buscadoc_mobile/utils/global.dart';

class Farmacia {
  final int id;
  final String nombre;
  final String descripcion;
  final String horarioEntrada;
  final String horarioSalida;
  final String telefono;
  final double latitud;
  final double longitud;
  final String? imagen;
  final String? responsableNombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Farmacia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.horarioEntrada,
    required this.horarioSalida,
    required this.telefono,
    required this.latitud,
    required this.longitud,
    this.imagen,
    this.responsableNombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farmacia.fromJson(Map<String, dynamic> json) {
    // 1. Extraemos los nodos dependiendo de si viene del controlador principal (dueño) o del buscador (user)
    final dueno = json['dueño'] ?? {};
    final ubicacionDueno = dueno['ubicacion'] ?? {};
    final user = json['user'] ?? {}; 

    // 2. Normalizamos la imagen (Tu formatFarmacia ya le aplica asset(), pero el buscador no)
    String? fotoRaw = dueno['foto'] ?? user['foto'];
    String? fotoFinal = fotoRaw;
    if (fotoRaw != null && !fotoRaw.startsWith('http')) {
      // Si solo es la ruta relativa, le pegamos la URL del servidor
      fotoFinal = '${Globals.webUrl}/storage/$fotoRaw';
    }

    return Farmacia(
      id: json['id'] ?? 0,
      nombre: json['nom_farmacia'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? '',
      horarioEntrada: _formatearHora(json['horario_entrada']),
      horarioSalida: _formatearHora(json['horario_salida']),
      telefono: json['telefono'] ?? 'No registrado', // Como lo quitaste del formatFarmacia, ponemos default
      
      // Coordenadas: Priorizamos el formatFarmacia (ubicacionDueno), luego el buscador (user)
      latitud: _parseDouble(ubicacionDueno['lat'] ?? user['latitud']),
      longitud: _parseDouble(ubicacionDueno['lng'] ?? user['longitud']),
      
      // Imagen y Nombre: Priorizamos formatFarmacia (dueno), luego el buscador (user)
      imagen: fotoFinal,
      responsableNombre: dueno['nombre'] ?? user['name'] ?? 'Sin responsable',
      
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // 👇 FUNCIÓN PARA OBTENER TODAS LAS FARMACIAS 👇
  static Future<List<Farmacia>> all() async {
    try {
      var url = Uri.parse('${Globals.webUrl}/api/farmacias');
      print('Consultando API Farmacias: $url');

      var response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        // Tu controlador devuelve { "success": true, "data": [...], "pagination": {...} }
        if (jsonResponse['success'] == true) {
          List<dynamic> listado = jsonResponse['data'] ?? [];
          
          List<Farmacia> farmacias = listado.map((item) => Farmacia.fromJson(item as Map<String, dynamic>)).toList();
          
          print("✅ Farmacias cargadas con éxito: ${farmacias.length}");
          return farmacias;
        } else {
          print('❌ Error de la API (Farmacias): ${jsonResponse['message']}');
          return [];
        }
      } else {
        print('❌ Falló la petición (Farmacias). Estado: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ ERROR DE CONEXIÓN AL TRAER FARMACIAS: $e');
      return [];
    }
  }

  // Funciones auxiliares de parseo
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _formatearHora(dynamic hora) {
    if (hora == null) return '--:--';
    if (hora.toString().contains(':')) {
      final partes = hora.toString().split(':');
      if (partes.length >= 2) return '${partes[0]}:${partes[1]}';
    }
    return hora.toString();
  }
}