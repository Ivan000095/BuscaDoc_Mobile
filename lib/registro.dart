import 'package:buscadoc_mobile/views/doctor/inicio.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  // Controladores Generales
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  final _tipoSangreController = TextEditingController();
  final _contactoEmergenciaController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _padecimientosController = TextEditingController();

  final _cedulaController = TextEditingController();
  final _costoController = TextEditingController();
  final _horaEntradaDocController = TextEditingController();
  final _horaSalidaDocController = TextEditingController();
  final _descDocController = TextEditingController();

  bool _estaCargando = false;

  Future<void> _procesarRegistro() async {
    setState(() => _estaCargando = true);

    // 1. Recolectar datos (Exactamente igual que antes)
    Map<String, dynamic> datos = {
      "name": _nombreController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "password_confirmation": _confirmPasswordController.text,
      "role": _rolSeleccionado,
      "f_nacimiento": _fechaNacimientoController.text,
      "latitud": _rolSeleccionado == 'doctor' ? _ubicacionDoctor.latitude : null,
      "longitud": _rolSeleccionado == 'doctor' ? _ubicacionDoctor.longitude : null,
    };

    if (_rolSeleccionado == 'doctor') {
      datos["cedula"] = _cedulaController.text;
      datos["costo"] = _costoController.text;
      datos["horario_entrada_doc"] = _horaEntradaDocController.text;
      datos["horario_salida_doc"] = _horaSalidaDocController.text;
      datos["descripcion"] = _descDocController.text;
    } else if (_rolSeleccionado == 'paciente') {
      datos["tipo_sangre"] = _tipoSangreController.text;
      datos["contacto_emergencia"] = _contactoEmergenciaController.text;
      datos["alergias"] = _alergiasController.text;
      datos["padecimientos"] = _padecimientosController.text;
    }

    var respuesta = await Usuario.registrar(datos);

    setState(() => _estaCargando = false);

    if (respuesta['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Bienvenido a BuscaDoc!'), backgroundColor: Colors.green)
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VistaInicio(title: 'BuscaDoc')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(respuesta['message']), backgroundColor: Colors.red)
        );
      }
    }
  }

  String _rolSeleccionado = 'paciente';
  
  LatLng _ubicacionDoctor = const LatLng(16.9060, -92.0934);

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MiTema.azulOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 30),
              Image.asset(
                'assets/logon.png',
                width: 200,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                '"Un lugar para todas tus necesidades"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF666666), fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
              
              Container(
                decoration: BoxDecoration(
                  color: MiTema.blanco,
                  borderRadius: BorderRadius.circular(30), // Tarjeta principal más redondeada
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Únete a BuscaDoc',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF000000)),
                    ),
                    const SizedBox(height: 24),
                    
                    _campoTexto('Nombre Completo', _nombreController, icono: Icons.person_outline),
                    _campoTexto('Correo electrónico', _emailController, icono: Icons.email_outlined),
                    _campoTexto('Contraseña', _passwordController, isPassword: true, icono: Icons.lock_outline),
                    _campoTexto('Confirmar contraseña', _confirmPasswordController, isPassword: true, icono: Icons.lock_reset_outlined),
                    _campoTexto('Fecha de Nacimiento (YYYY-MM-DD)', _fechaNacimientoController, icono: Icons.calendar_today_outlined),
                    
                    const Divider(height: 40),

                    const Text(
                      'TIPO DE PERFIL',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    
                    DropdownButtonFormField<String>(
                      value: _rolSeleccionado,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: Icon(Icons.badge_outlined, color: MiTema.azulOscuro),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none), // Borde 50%
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'paciente', child: Text('Paciente (Busco atención)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'doctor', child: Text('Doctor (Ofrezco servicios)', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (String? nuevoValor) {
                        if (nuevoValor != null) {
                          setState(() {
                            _rolSeleccionado = nuevoValor;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    if (_rolSeleccionado == 'paciente') _formularioPaciente(),
                    if (_rolSeleccionado == 'doctor') _formularioDoctor(),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _estaCargando ? null : _procesarRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MiTema.azulOscuro,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), // Botón de píldora
                        elevation: 5,
                      ),
                      child: Text(
                        'Registrarme',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MiTema.blanco, letterSpacing: 1.2),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? ', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => const InicioSesion())
                          ),
                          child: Text(
                            'Inicia sesión',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String etiqueta, TextEditingController controlador, {bool isPassword = false, IconData? icono}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controlador,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: icono != null ? Icon(icono, color: MiTema.azulOscuro) : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50), 
            borderSide: BorderSide(color: MiTema.azulOscuro, width: 2)
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }

  Widget _formularioPaciente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DATOS MÉDICOS BÁSICOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        _campoTexto('Tipo de Sangre', _tipoSangreController, icono: Icons.bloodtype_outlined),
        _campoTexto('Contacto Emergencia', _contactoEmergenciaController, icono: Icons.phone_in_talk_outlined),
        _campoTexto('Alergias', _alergiasController, icono: Icons.medical_information_outlined),
        _campoTexto('Padecimientos', _padecimientosController, icono: Icons.sick_outlined),
      ],
    );
  }

  Widget _formularioDoctor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DATOS DE TRABAJO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        _campoTexto('Cédula Profesional', _cedulaController, icono: Icons.assignment_ind_outlined),
        _campoTexto('Costo por consulta (\$)', _costoController, icono: Icons.attach_money),
        _campoTexto('Horario de entrada (Ej. 08:00)', _horaEntradaDocController, icono: Icons.access_time),
        _campoTexto('Horario de salida (Ej. 18:00)', _horaSalidaDocController, icono: Icons.access_time_filled),
        _campoTexto('Descripción de su trabajo', _descDocController, icono: Icons.description_outlined),
        
        const SizedBox(height: 10),
        const Text('UBICACIÓN DEL CONSULTORIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('Mueve el mapa y toca para fijar la ubicación exacta:', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),
        
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MiTema.azulOscuro.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _ubicacionDoctor,
                zoom: 15.0,
              ),
              onTap: (LatLng nuevaPosicion) {
                setState(() {
                  _ubicacionDoctor = nuevaPosicion;
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('pin_consultorio'),
                  position: _ubicacionDoctor,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
        ),
      ],
    );
  }
}