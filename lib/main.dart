import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xd/model/db.dart';
import 'package:xd/model/usuarios.dart';
import 'package:xd/theme/tema.dart';
import 'package:xd/view/citas.dart';
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
        '/cita': (context) => AgendarCitaPage(title: 'te amo brava'),
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
  // Controladores para los campos
  final TextEditingController _ctrlEmail = TextEditingController();
  final TextEditingController _ctrlPwd = TextEditingController();
  late Database db;

  void initstate() async {
    _abreBD();
    super.initState();
  }

  Future<bool> _abreBD() async {
    db = await BaseDatos.abreBD();
    return true;
  }

  // Método void para validar credenciales locales
  void _validarCredenciales() async {
    if (_ctrlEmail.text.isEmpty || _ctrlPwd.text.isEmpty){
      SnackBar mensaje = SnackBar(content: Text("pendejo, rellénalo", style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
      ScaffoldMessenger.of(context).showSnackBar(mensaje);
    } else {
    bool respuesta = await Usuario.valida(
      db,
      _ctrlEmail.text.trim(),
      _ctrlPwd.text,
    );
    if (respuesta) {
      // Éxito: navegar a inicio
      Navigator.pushNamed(context, '/inicio');
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario y/o contraseña incorrecta pendejoooo', 
          style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        ),
      );
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.azulblanco,
      body: FutureBuilder(
        future: _abreBD(),
        builder: (context, snapshot) {
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
                  FooterSection(),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _vienvenida() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/login.png', width: 200),
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
          controller: _ctrlEmail, // ← Añadido controlador
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
          controller: _ctrlPwd, // ← Añadido controlador
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
            onPressed: _validarCredenciales, // ← Llama al método de validación
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

// PIE DE PÁGINA (sin cambios)
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
