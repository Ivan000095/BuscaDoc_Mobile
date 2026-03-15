import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:buscadoc_mobile/utils/global.dart';

class Especialidades {
  int id;
  String nombre;

  Especialidades({
    required this.id,
    required this.nombre
  });

  factory Especialidades.fromJson(Map<String, dynamic> json) {
    return Especialidades(
      id: json['id'],
      nombre: json['name'] ?? 'Sin nombre', 
    );
  }

  static Future<List<Especialidades>> all() async {
    try {
      var url = Uri.parse('${Globals.webUrl}/api/especialidades');
      print('Consultando API Especialidades: $url');

      var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse['success'] == true) {
          List<dynamic> dataList = jsonResponse['data'];
        
          List<Especialidades> especialidades = dataList.map((item) {
            return Especialidades.fromJson(item);
          }).toList();

          print("✅ Especialidades cargadas: ${especialidades.length}");
          return especialidades;
        } else {
          print('❌ Error de la API: ${jsonResponse['message']}');
          return [];
        }
      } else {
        print('❌ Fallo la petición con estado: ${response.statusCode}. Detalle: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error de conexión al traer especialidades: $e');
      return [];
    }
  }
}