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
}