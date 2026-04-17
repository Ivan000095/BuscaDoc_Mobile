// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:buscadoc_mobile/model/comentarios.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class Doctores {
  int id;
  int idUsuario;
  String especialidad;
  String nombre;
  String descripcion;
  DateTime fecha;
  String image;
  String telefono;
  String idioma;
  String cedula;
  String rol;
  int horarioentrada;
  int horariosalida;
  num costos;
  double? promedio;
  final List<Comentario> comentarios;

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
    required this.idUsuario,
    required this.cedula,
    required this.rol,
    required this.costos,
    required this.promedio,
    required this.comentarios,
  });

  static Future<List<Doctores>> all() async {
    try {
      var url = Uri.parse('${Globals.webUrl}/api/doctors');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        List listado = jsonResponse['data'] ?? [];
        print(listado);
        List<Doctores> doctores = [];

        for (var element in listado) {
          String costoString = element['costos']?.toString().replaceAll('\$', '').replaceAll(',', '') ?? '0';
          List rawComentarios = element['comentarios'] ?? [];
          print(rawComentarios);
          List<Comentario> listaComentarios = rawComentarios
              .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
              .toList();
          doctores.add(
            Doctores(
              id: element['id'] ?? 0,
              idUsuario: element['user_id'],
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
              rol: element['role'],
              costos: num.tryParse(costoString) ?? 0,
              promedio: element['promedio'] != null ? element['promedio'].toDouble() : 0.0,
              comentarios: listaComentarios,
            ),
          );
        }
        
        print("Doctores cargados con éxito: ${doctores.length}");
        return doctores;
        
      } else {
        print('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR AL CONVERTIR DATOS: $e');
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

  factory Doctores.fromJson(Map<String, dynamic> element) {
    String costoString = element['costos']?.toString().replaceAll('\$', '').replaceAll(',', '') ?? '0';
    
    List rawComentarios = element['comentarios'] ?? [];
    List<Comentario> listaComentarios = rawComentarios
        .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
        .toList();

    String nombreFinal = 'Sin nombre';
    if (element['user'] != null && element['user']['name'] != null) {
      nombreFinal = element['user']['name'];
    } else {
      nombreFinal = element['name']?.toString() ?? element['nombre']?.toString() ?? 'Sin nombre';
    }

    String fotoFinal = 'https://via.placeholder.com/150';
    if (element['user'] != null && element['user']['foto'] != null) {
      fotoFinal = element['user']['foto'];
    } else if (element['image'] != null) {
      fotoFinal = element['image'].toString();
    }

    String especialidadFinal = 'Sin especialidad';
    if (element['especialidades'] != null && (element['especialidades'] as List).isNotEmpty) {
      especialidadFinal = element['especialidades'][0]['nombre'];
    } else {
      especialidadFinal = element['especialidad']?.toString() ?? 'Sin especialidad';
    }


    return Doctores(
      id: element['id'] ?? 0,
      idUsuario: element['user_id'] ?? 0,
      especialidad: especialidadFinal,
      nombre: nombreFinal,
      descripcion: element['descripcion']?.toString() ?? '',
      fecha: element['fecha'] != null
          ? DateTime.tryParse(element['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      image: '${Globals.webUrl}/storage/$fotoFinal',
      telefono: element['telefono']?.toString() ?? '',
      horarioentrada: _parsearHora(element['horarioentrada'] ?? element['horario_entrada']),
      horariosalida: _parsearHora(element['horariosalida'] ?? element['horario_salida']),
      idioma: element['idioma']?.toString() ?? element['idiomas']?.toString() ?? '',
      cedula: element['cedula']?.toString() ?? '',
      rol: element['role'] ?? "Doctor",
      costos: num.tryParse(costoString) ?? element['costo'] ?? 0,
      promedio: element['promedio'] != null ? element['promedio'].toDouble() : 0.0,
      comentarios: listaComentarios,
    );
  }
}
