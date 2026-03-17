import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:buscadoc_mobile/home.dart';

import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'registro.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/utils/ui.dart';


class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _estaCargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _valida() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'Por favor llena todos los campos', MiTema.rojoerror, Colors.white, icono: Icons.warning);
      return;
    }

    setState(() => _estaCargando = true);

    var respuesta = await Usuario.login(
      _emailController.text.trim(), 
      _passwordController.text
    );

    setState(() => _estaCargando = false);

    if (respuesta['success']) {
      print("Token recibido: ${respuesta['token']}");
      final userData = respuesta['user'];
      final String userRole = userData['role'];
      final String userName = userData['name'];
      final String userFoto = userData['foto'];
      final String userEmail = userData['email'];

      if (mounted) {
        UIUtils.showRoundedSnackBar(context, '¡Inición sesiada!', MiTema.verde, Colors.white, icono: Icons.check_circle);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VistaInicio(
              title: "BuscaDoc",
              role: userRole,
              userName: userName,
              userFoto: userFoto,
              userEmail: userEmail
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, respuesta['message'], MiTema.rojoerror, Colors.white, icono: Icons.warning);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MiTema.azulOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
          color: MiTema.blanco,
        ),
      ),
      backgroundColor: MiTema.gris,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/logon.png',
                width: 200,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                '"Un lugar para todas tus necesidades"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 50),
              // Tarjeta de formulario
              Container(
                decoration: BoxDecoration(
                  color: MiTema.blanco,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    const Text(
                      'Iniciar sesión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Campo de correo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: MiTema.gris,
                            prefixIcon: const Icon(BootstrapIcons.envelope, color: Color.fromARGB(255, 11, 13, 78),size: 20 ,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Campo de contraseña
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: MiTema.gris,
                            prefixIcon: const Icon(BootstrapIcons.lock, color: Color.fromARGB(255, 11, 13, 78),size: 20 ,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _estaCargando ? null : _valida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MiTema.azulOscuro,
                        disabledBackgroundColor: MiTema.azulOscuro.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: _estaCargando
                          ? const SizedBox(
                              height: 20, 
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: MiTema.blanco,
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'O',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Botones de redes sociales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botón Google
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(BootstrapIcons.google, size: 20),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              side: const BorderSide(
                                color: Color(0xFFDDDDDD),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(200),
                              ),
                            ),
                            iconAlignment: IconAlignment.start,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botón Facebook
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(BootstrapIcons.facebook, size: 28),
                            label: const Text('Facebook'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(
                                color: Color(0xFFDDDDDD),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                              ),
                            ),
                            iconAlignment: IconAlignment.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Enlace de registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Aún no tienes cuenta? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Registro(),
                              ),
                            );
                          },
                          child: Text(
                            'Registrarme',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: MiTema.azulOscuro,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
