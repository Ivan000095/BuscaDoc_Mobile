import 'package:sqflite/sqflite.dart';

class Usuario {
  int id;
  String correo;
  String pass;

  Usuario({
    required this.id,
    required this.correo,
    required this.pass,
  });

  static Future<bool> valida(Database db, String m, String p) async {
    List resultado = await db.query("usuarios", where: "correo = ? AND pass = ?", whereArgs: [m, p]);
    
    if (resultado.isNotEmpty) {
      return true;
    }
    return false;
  }

  // static Future<bool<Valida>> all() async {
  //   try {
  //     var url = Uri.http('10.0.2.2:8000', '/api/auth/login');
      
  //     var response = await http.get(url, headers: {"Accept": "application/json"});

  //     if (response.statusCode == 200) {
  //       var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
  //       if (jsonResponse['Respuesta'] == 'Bienvenido') {
  //         MyApp.token = jsonResponse['datos']['token'];
  //       }
  //       return true;
  //     } else {
  //       print('❌ Error del servidor: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('🔴 ERROR DE CONEXIÓN: $e');
  //   }
  //   return [];
  // }
}