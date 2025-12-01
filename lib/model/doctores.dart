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
  String direccion;
  num costos;

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
    required this.direccion,
    required this.costos,
  });

  static Future<List<Doctores>> all() async {
    try {
      // 📡 URL LOCAL (Asegúrate que el puerto 8000 sea el correcto)
      var url = Uri.http('10.0.2.2:8000', '/api/doctors');
      
      var response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extraemos la data
        List listado = jsonResponse['data'] ?? [];
        List<Doctores> doctores = [];

        for (var element in listado) {
          doctores.add(
            Doctores(
              id: element['id'] ?? 0,
              especialidad: element['especialidad'] ?? 'Sin especialidad',
              nombre: element['name'] ?? element['nombre'] ?? 'Sin nombre',
              descripcion: element['descripcion'] ?? '',
              fecha: element['fecha'] != null 
                  ? DateTime.tryParse(element['fecha'].toString()) ?? DateTime.now() 
                  : DateTime.now(),
              image: element['image'] as String,
              telefono: element['telefono'] ?? '',
              horarioentrada: _parsearHora(element['horarioentrada']),
              horariosalida: _parsearHora(element['horariosalida']),
              idioma: element['idioma'] ?? '',
              cedula: element['cedula'] ?? '',
              direccion: element['direccion'] ?? '',
              costos: num.tryParse(element['costos'].toString()) ?? 0,
            ),
          );
        }
        return doctores;
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 ERROR DE CONEXIÓN: $e');
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
    
    // Convertimos a string por si acaso
    String horaTexto = horaRaw.toString(); 
    
    // Si viene vacía, retornamos 0
    if (horaTexto.isEmpty) return 0;

    try {
      // Separamos por los dos puntos ":"
      // "14:00:00" se convierte en una lista ["14", "00", "00"]
      List<String> partes = horaTexto.split(':');
      
      // Tomamos la primera parte ("14") y la convertimos a entero
      if (partes.isNotEmpty) {
        return int.parse(partes[0]);
      }
    } catch (e) {
      print("Error parseando hora: $horaTexto");
    }
    
    return 0; // Si todo falla, devuelve 0
  }

  /* CONSULTA LOCAL
  static Future<List<Doctores>> all(Database db) async {
    List resultado = await db.query("doctores");
    List<Doctores> doctores = [];

    for(dynamic element in resultado) {
      await _agregaDoc(element, doctores, db);
    }
    return doctores;
  }

  static Future<bool> _agregaDoc(element, doctores, db) async {
    doctores.add(
        Doctores(
          id: element['id'] as int,
          especialidad: element['especialidad'] as String,
          nombre: element['nombre'] as String,
          descripcion: element['descripcion'] as String,
          fecha: DateTime.parse(element['fecha'] as String),
          image: element['image'] as String,
          telefono: element['telefono'] as String,
          horarioentrada: element['horarioentrada'] as int,
          horariosalida: element['horariosalida'] as int,
          idioma: element['idioma'] as String,
          cedula: element['cedula'] as String,
          direccion: element['direccion'] as String,
          costos: element['costos'] as int,
        ),
      );
    return true;
  }
}
  static List<Doctores> all() {
    //   Doctores d1 = Doctores(
    //     id: 1,
    //     especialidad: 'Ginecólogo',
    //     nombre: 'Jesús Acacio',
    //     descripcion: 'Acacio hacerrato ivan caminando',
    //     fecha: DateTime(2006, 1, 20),
    //     image: 'assets/jesus.jpg',
    //     telefono: '919 676 7676',
    //     horarioentrada: 8,
    //     horariosalida: 20,
    //     idioma: 'Tzeltal, Inglés y español',
    //     cedula: '1234567',
    //     direccion: 'Calle 5 #123, San Cristóbal de las Casas',
    //     costos: 500.0,
    //   );
    //   Doctores d2 = Doctores(
    //     id: 2,
    //     especialidad: 'Dentista',
    //     nombre: 'John Lennon',
    //     descripcion: 'holallholalhola',
    //     fecha: DateTime(1940, 10, 9),
    //     image: 'assets/john.webp',
    //     telefono: '123456789',
    //     horarioentrada: 11,
    //     horariosalida: 15,
    //     idioma: 'Inglés',
    //     cedula: '7654321',
    //     direccion: 'Av. Revolución #456, Tuxtla Gutiérrez',
    //     costos: 350.0,
    //   );
    //   Doctores d3 = Doctores(
    //     id: 3,
    //     especialidad: 'Ingeniero',
    //     nombre: 'Jose Ivan',
    //     descripcion: 'el novio de Bere',
    //     fecha: DateTime(2006, 3, 17),
    //     image: 'assets/jesus.jpg',
    //     telefono: '919 135 8054',
    //     horarioentrada: 20,
    //     horariosalida: 12,
    //     idioma: 'C++',
    //     cedula: '8910112',
    //     direccion: 'Calle del Sol #789, Comitán',
    //     costos: 600.0,
    //   );
    //   Doctores d4 = Doctores(
    //     id: 4,
    //     especialidad: 'Especialito',
    //     nombre: 'Toromax',
    //     descripcion: 'yiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
    //     fecha: DateTime(2001, 4, 20),
    //     image: 'assets/toromax}.jpeg',
    //     telefono: '919 135 8054',
    //     horarioentrada: 2,
    //     horariosalida: 23,
    //     idioma: 'yiii',
    //     cedula: '8910112',
    //     direccion: 'Calle del Sol #789, Comitán',
    //     costos: 600.0,
    //   );
    //   return [d1, d2, d3, d4];
    // } */
}