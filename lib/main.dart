import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xd/model/db.dart';
import 'package:xd/model/usuarios.dart';
import 'package:xd/theme/tema.dart';
import 'package:xd/view/inicio.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:xd/view/vistaentrega.dart';

void main() {
  runApp(GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi app',
      theme: MiTema.temaApp(context),
      home: LoginScreen(),
      routes: {
        '/inicio': (context) => const VistaInicio(title: 'BuscaDoc'),
        '/main': (context) => const MyApp(),
        '/vistaentrega': (context) => VistaEntrega(title: 'BuscaDoc'),
        // '/cita': (context) => AgendarCitaPage(title: 'te amo brava'), // Comentado si no usas esta ruta aún
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _ctrlEmail = TextEditingController();
  final TextEditingController _ctrlPwd = TextEditingController();
  late Database db;
  
  late Future<bool> _futureInicializacion;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de la BD una sola vez
    _futureInicializacion = _abreBD();
  }

  // Modificado para capturar errores
  Future<bool> _abreBD() async {
    try {
      db = await BaseDatos.abreBD();
      print("Base de datos abrida correctamente");
      return true;
    } catch (e) {
      print("ERROR CRÍTICO AL ABRIR BD: $e");
      // Lanzamos el error para que el FutureBuilder lo detecte
      throw Exception("No se pudo abrir la BD: $e");
    }
  }

  void _validarCredenciales() async {
    if (_ctrlEmail.text.isEmpty || _ctrlPwd.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, rellena los campos", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        bool respuesta = await Usuario.valida(
          db,
          _ctrlEmail.text.trim(),
          _ctrlPwd.text,
        );
        if (respuesta) {
          if (mounted) Navigator.pushNamed(context, '/inicio');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario y/o contraseña incorrecta', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print("Error validando usuario: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.azulblanco,
      body: FutureBuilder<bool>(
        future: _futureInicializacion, 
        builder: (context, snapshot) {
          // 1. Si hay error, lo mostramos en pantalla
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "Error al cargar:\n${snapshot.error}", 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          // 2. Si terminó y tiene datos, mostramos el login
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  _vienvenida(),
                  const SizedBox(height: 10),
                  _email(),
                  _pass(),
                  const SizedBox(height: 30),
                  _boton(),
                  const SizedBox(height: 15),
                  _botongoogle(),
                  const SizedBox(height: 20),
                  const FooterSection(),
                ],
              ),
            );
          } 
          
          // 3. Si no ha terminado, mostramos cargando
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _vienvenida() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/login.png', width: 200, errorBuilder: (c,e,s)=> const Icon(Icons.person, size: 100)),
        const SizedBox(height: 10),
        Text(
          '¡Bienvenido!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MiTema.negro,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo electrónico:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrlEmail,
          decoration: InputDecoration(
            hintText: 'Correo electrónico',
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: MiTema.azulavanda),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: MiTema.negro, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _pass() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrlPwd,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: MiTema.azulMarino,
                style: BorderStyle.solid,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: MiTema.negro, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _boton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validarCredenciales,
            style: ElevatedButton.styleFrom(
              backgroundColor: MiTema.azulMarino,
              foregroundColor: MiTema.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _botongoogle() {
    return SizedBox(
      width: 200,
      height: 45,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.g_mobiledata, size: 35),
        label: const Text('Ingresar con Google'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: MiTema.azulMarino),
          foregroundColor: MiTema.negro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿Aún no te has registrado? '),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Crear cuenta',
                style: TextStyle(
                  color: MiTema.verdeazulado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Text('¿Has olvidado tu contraseña?'),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Recuperar aqui',
            style: TextStyle(
              color: MiTema.verdeazulado,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}