// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class Doctores {
  int id;
  String especialidad;
  String nombre;
  String descripcion;
  DateTime fecha;
  String image;
  String telefono;
  String idioma;
  String cedula;
  int horarioentrada;
  int horariosalida;
  num costos;
  double? promedio;

  Doctores({
    required this.id,
    required this.especialidad,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.image,
    required this.telefono,
    required this.horarioentrada,
    required this.horariosalida,
    required this.idioma,
    required this.cedula,
    required this.costos,
    required this.promedio,
  });

  static Future<List<Doctores>> all() async {
    try {
      var url = Uri.http('localhost:8000', '/api/doctors');
      var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer 42|g2CRhU1BjuXHFOU2PENl1wetSWnMHj3dhxcDVPzae816f21e",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extraemos la data
        List listado = jsonResponse['data'] ?? [];
        print(listado);
        List<Doctores> doctores = [];

        for (var element in listado) {
          String costoString = element['costos']?.toString().replaceAll('\$', '').replaceAll(',', '') ?? '0';

          doctores.add(
            Doctores(
              id: element['id'] ?? 0,
              especialidad: element['especialidad']?.toString() ?? 'Sin especialidad',
              nombre: element['name']?.toString() ?? element['nombre']?.toString() ?? 'Sin nombre',
              descripcion: element['descripcion']?.toString() ?? '',
              fecha: element['fecha'] != null
                  ? DateTime.tryParse(element['fecha'].toString()) ?? DateTime.now()
                  : DateTime.now(),
                  
              image: element['image']?.toString() ?? 'https://via.placeholder.com/150',
              
              telefono: element['telefono']?.toString() ?? '',
              horarioentrada: _parsearHora(element['horarioentrada']),
              horariosalida: _parsearHora(element['horariosalida']),
              idioma: element['idioma']?.toString() ?? '',
              cedula: element['cedula']?.toString() ?? '',
              costos: num.tryParse(costoString) ?? 0,
              promedio: element['promedio'] != null ? element['promedio'].toDouble() : 0.0,
            ),
          );
        }
        
        print("✅ Doctores cargados con éxito: ${doctores.length}");
        return doctores;
        
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // Si algo falla, ahora sí veremos el error exacto en la consola
      print('🔴 ERROR AL CONVERTIR DATOS: $e');
    }
    return [];
  }

  /* URL de imágenes
  static String _fixImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://via.placeholder.com/150';
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:8000/$path'; 
  }*/

  static int _parsearHora(dynamic horaRaw) {
    if (horaRaw == null) return 0;
    String horaTexto = horaRaw.toString();
    if (horaTexto.isEmpty) return 0;
    try {
      List<String> partes = horaTexto.split(':');
      if (partes.isNotEmpty) {
        return int.parse(partes[0]);
      }
    } catch (e) {
      print("Error parseando hora: $horaTexto");
    }
    return 0;
  }
}
