import 'package:sqflite/sqflite.dart';

class BaseDatos {
  static Future<Database> abreBD() async{
      // obtener la ubicación de la bd
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath/buscadoc4.db' ;

    // abrir la base de datos
    Database database = await openDatabase(
      path, 
      version: 1,
      onCreate: (Database db, int version) async {

        // crear la tabla de usuarios
        await db.execute(
            'CREATE TABLE usuarios (id INTEGER PRIMARY KEY, correo TEXT, pass TEXT)');

        // pruebas
        await db.execute(
            '''INSERT INTO usuarios VALUES(1, 'admin', '4dm1n')''');

        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE doctores (id INTEGER PRIMARY KEY, especialidad TEXT, nombre TEXT, descripcion TEXT, fecha TEXT, image TEXT, telefono TEXT, idioma TEXT, cedula TEXT, direccion TEXT, costos INTEGER, horarioentrada INTEGER, horariosalida INTEGER)');

        await db.execute(
            '''INSERT INTO doctores (
                id, especialidad, nombre, descripcion, fecha, image, telefono, idioma, cedula, direccion, costos, horarioentrada, horariosalida)
              VALUES(
                1, 
                'Ginecologo',
                'Jesús Acacio',
                'Acacio hacerrato ivan caminando',
                '2006-01-20 00:00:00',
                'assets/jesus.jpg',
                '919 676 7676',
                'Tzeltal, Inglés y español',
                '1234567',
                'Calle 5 #123, San Cristóbal de las Casas',
                500,
                8,
                23
              )
            '''
          );
          await db.execute(
            '''INSERT INTO doctores (
                id, especialidad, nombre, descripcion, fecha, image, telefono, idioma, cedula, direccion, costos, horarioentrada, horariosalida)
              VALUES(
                2, 
                'Ginecologo',
                'John Lennon',
                'holallholalhola',
                '1940-10-09 00:00:00',
                'assets/john.webp',
                '919 676 7676',
                'Inglés',
                '1234567',
                'Calle 5 #123, San Cristóbal de las Casas',
                500,
                8,
                23
              )
            '''
          );
          await db.execute(
            '''INSERT INTO doctores (
                id, especialidad, nombre, descripcion, fecha, image, telefono, idioma, cedula, direccion, costos, horarioentrada, horariosalida)
              VALUES(
                3, 
                'Especialito',
                'Toromax',
                'yiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
                '2001-04-20 00:00:00',
                'assets/toromax}.jpeg',
                '919 676 7676',
                'Inglés',
                '1234567',
                'Calle 5 #123, San Cristóbal de las Casas',
                500,
                8,
                23
              )
            '''
          );
        });
    return database;
  }
}