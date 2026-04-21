import 'package:buscadoc_mobile/home.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'registro.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:magicoon_icons/magicoon.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _estaCargando = false;
  bool _obscurePassword = true; // Control del ojito de la contraseña

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _valida() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'Por favor llena todos los campos',
          MiTema.rojoerror, Colors.white,
          icono: Icons.warning);
      return;
    }

    setState(() => _estaCargando = true);

    var respuesta = await Usuario.login(
        _emailController.text.trim(), _passwordController.text);

    setState(() => _estaCargando = false);

    if (respuesta['success']) {
      final userData = respuesta['user'];
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, '¡Bienvenido de nuevo!',
            MiTema.verde, Colors.white,
            icono: MagicoonFilled.checkCircle);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VistaInicio(
              title: "BuscaDoc",
              role: userData['role'],
              userName: userData['name'],
              userFoto: userData['foto'] ?? '',
              userEmail: userData['email'],
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, respuesta['message'],
            MiTema.rojoerror, Colors.white,
            icono: Icons.warning);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Un gris azulado muy claro y moderno
      body: Stack(
        children: [
          // Fondo decorativo superior
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: MiTema.azulOscuro,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo con sombra blanca sutil
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logob.png',
                        width: 180,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Tu salud, en un solo lugar",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Tarjeta Principal
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: MiTema.azulOscuro.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '¡Hola de nuevo!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MiTema.azulOscuro,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresa tus credenciales para continuar',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 30),
                          
                          // Campo Email
                          _buildTextField(
                            label: 'Correo electrónico',
                            controller: _emailController,
                            icon: MagicoonRegular.envelope,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          
                          // Campo Password
                          _buildTextField(
                            label: 'Contraseña',
                            controller: _passwordController,
                            icon: MagicoonRegular.lock,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            togglePassword: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          
                          const SizedBox(height: 20),

                          // Botón Login
                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _estaCargando ? null : _valida,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MiTema.azulOscuro,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shadowColor: MiTema.azulOscuro.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: _estaCargando
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Aún no tienes cuenta? ', style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Registro())),
                          child: Text(
                            'Regístrate aquí',
                            style: TextStyle(
                              color: MiTema.azulOscuro,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los campos de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            prefixIcon: Icon(icon, color: MiTema.azulOscuro, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: togglePassword,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: label == 'Correo electrónico' ? 'ejemplo@correo.com' : '••••••••',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ),
      ],
    );
  }

}