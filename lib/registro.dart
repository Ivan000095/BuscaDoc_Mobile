import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/model/especialidad.dart';
import 'package:buscadoc_mobile/utils/ui.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
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
  final _idiomasController = TextEditingController();

  bool _estaCargando = false;

  File? _fotoPerfil;
  final ImagePicker _picker = ImagePicker();

  String _rolSeleccionado = 'paciente';
  
  LatLng _ubicacionDoctor = const LatLng(16.9060, -92.0934);
  GoogleMapController? _mapController;
  
  List<Especialidades> _listaEspecialidades = [];
  int? _especialidadIdSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      _listaEspecialidades = await Especialidades.all();
      if(mounted) setState(() {}); // Actualizamos la vista si ya llegaron
    } catch (e) {
      print("Error cargando especialidades: $e");
    }

    // 2. Pedimos la ubicación del GPS
    await _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _ubicacionDoctor = LatLng(posicion.latitude, posicion.longitude);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_ubicacionDoctor, 16.0));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fechaNacimientoController.dispose();
    _tipoSangreController.dispose();
    _contactoEmergenciaController.dispose();
    _alergiasController.dispose();
    _padecimientosController.dispose();
    _cedulaController.dispose();
    _costoController.dispose();
    _horaEntradaDocController.dispose();
    _horaSalidaDocController.dispose();
    _descDocController.dispose();
    _idiomasController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (imagenSeleccionada != null) {
        setState(() {
          _fotoPerfil = File(imagenSeleccionada.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar foto: $e");
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    DateTime fechaInicial = DateTime.now().subtract(const Duration(days: 365 * 18));
    
    if (_fechaNacimientoController.text.isNotEmpty) {
      try {
        fechaInicial = DateTime.parse(_fechaNacimientoController.text);
      } catch (e) {
        // no me impota
      }
    }

    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1920), 
      lastDate: DateTime.now(),  
      helpText: 'SELECCIONA TU FECHA DE NACIMIENTO',
      cancelText: 'CANCELAR',
      confirmText: 'GUARDAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MiTema.azulOscuro,
              onPrimary: MiTema.blanco,   
              onSurface: MiTema.negro,    
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: MiTema.azulOscuro),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null && mounted) {
      setState(() {
        _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
      });
    }
  }

  Future<void> _seleccionarHoraRelojInteractivo(TextEditingController controller) async {
    Time initialTime = Time(hour: 8, minute: 0);
    
    if (controller.text.isNotEmpty) {
      try {
        final List<String> parts = controller.text.split(':');
        initialTime = Time(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        // yo guapo
      }
    }

    Navigator.of(context).push(
      showPicker(
        context: context,
        value: initialTime,
        onChange: (newTime) {
          setState(() {
            final now = DateTime.now();
            final dt = DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute);
            controller.text = DateFormat('HH:mm:00').format(dt);
          });
        },
        is24HrFormat: true, 
        accentColor: MiTema.azulOscuro, 
        unselectedColor: Colors.grey.shade400,
        cancelText: "CANCELAR",
        okText: "GUARDAR",
        okStyle: TextStyle(fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
        cancelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
        borderRadius: 20, 
      ),
    );
  }

  Future<void> _procesarRegistro() async {
    if (_rolSeleccionado == 'doctor' && _especialidadIdSeleccionada == null) {
      UIUtils.showRoundedSnackBar(context, 'Seleccione una especialidad', MiTema.rojoerror, MiTema.blanco);
    }

    setState(() => _estaCargando = true);

    Map<String, dynamic> datos = {
      "name": _nombreController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
      "password_confirmation": _confirmPasswordController.text,
      "role": _rolSeleccionado,
      "f_nacimiento": _fechaNacimientoController.text,
      "latitud": _rolSeleccionado == 'doctor' ? _ubicacionDoctor.latitude : null,
      "longitud": _rolSeleccionado == 'doctor' ? _ubicacionDoctor.longitude : null,
    };

    if (_rolSeleccionado == 'doctor') {
      datos["cedula"] = _cedulaController.text.trim();
      datos["costo"] = _costoController.text.trim();
      datos["idiomas"] = _idiomasController.text.trim(); 
      datos["horario_entrada_doc"] = _horaEntradaDocController.text.isNotEmpty 
        ? _horaEntradaDocController.text 
        : "08:00:00";
          
      datos["horario_salida_doc"] = _horaSalidaDocController.text.isNotEmpty 
        ? _horaSalidaDocController.text 
        : "18:00:00";
      datos["descripcion"] = _descDocController.text.trim();
      datos["especialidades"] = [_especialidadIdSeleccionada]; 
    } else if (_rolSeleccionado == 'paciente') {
      datos["tipo_sangre"] = _tipoSangreController.text.trim();
      datos["contacto_emergencia"] = _contactoEmergenciaController.text.trim();
      datos["alergias"] = _alergiasController.text.trim();
      datos["padecimientos"] = _padecimientosController.text.trim();
    }

    var respuesta = await Usuario.registrar(datos, fotoPerfil: _fotoPerfil);

    setState(() => _estaCargando = false);

    if (respuesta['success']) {
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, '¡Bienvenido a BuscaDoc!', MiTema.verde, MiTema.blanco);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InicioSesion()));
      }
    } else {
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, respuesta['message'], MiTema.rojoerror, MiTema.blanco);
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
                  borderRadius: BorderRadius.circular(30),
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

                    Center(
                      child: GestureDetector(
                        onTap: _seleccionarFoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(color: MiTema.azulOscuro, width: 3),
                                image: _fotoPerfil != null
                                    ? DecorationImage(
                                        image: FileImage(_fotoPerfil!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _fotoPerfil == null
                                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: MiTema.azulOscuro,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: MiTema.blanco, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Toca para subir una foto",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    
                    _campoTexto('Nombre Completo', _nombreController, icono: Icons.person_outline),
                    _campoTexto('Correo electrónico', _emailController, icono: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    _campoTexto('Contraseña', _passwordController, isPassword: true, icono: Icons.lock_outline),
                    _campoTexto('Confirmar contraseña', _confirmPasswordController, isPassword: true, icono: Icons.lock_reset_outlined),
                    
                    _campoTexto(
                      'Fecha de Nacimiento', 
                      _fechaNacimientoController, 
                      icono: Icons.calendar_today_outlined,
                      readOnly: true, 
                      onTap: _seleccionarFechaNacimiento, 
                    ),
                    
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 5,
                      ),
                      child: _estaCargando 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
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

  Widget _campoTexto(String etiqueta, TextEditingController controlador, {bool isPassword = false, IconData? icono, bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controlador,
        obscureText: isPassword,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
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
        _campoTexto('Contacto Emergencia', _contactoEmergenciaController, icono: Icons.phone_in_talk_outlined, keyboardType: TextInputType.phone),
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
        
        // 🔥 AGREGADO: DROPDOWN DE ESPECIALIDADES 🔥
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: _especialidadIdSeleccionada,
            icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.star_border, color: MiTema.azulOscuro, size: 20),
              labelText: "Especialidad",
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            items: _listaEspecialidades.isEmpty 
                ? null 
                : _listaEspecialidades.map((Especialidades especialidad) {
                    return DropdownMenuItem<int>(
                      value: especialidad.id, 
                      child: Text(especialidad.nombre, overflow: TextOverflow.ellipsis), 
                    );
                  }).toList(),
            onChanged: _listaEspecialidades.isEmpty 
                ? null 
                : (int? nuevoId) {
                    setState(() {
                      _especialidadIdSeleccionada = nuevoId;
                    });
                  },
          ),
        ),

        _campoTexto('Cédula Profesional', _cedulaController, icono: Icons.assignment_ind_outlined),
        _campoTexto('Costo por consulta (\$)', _costoController, icono: Icons.attach_money, keyboardType: TextInputType.number),
        _campoTexto('Idiomas (Ej. Español, Inglés)', _idiomasController, icono: Icons.language),
        _campoTexto('Descripción de su trabajo', _descDocController, icono: Icons.description_outlined),
        
        const SizedBox(height: 10),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 8),
                    child: Text(
                      "ENTRADA".toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  InkWell(
                    onTap: () => _seleccionarHoraRelojInteractivo(_horaEntradaDocController),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 100, 
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: MiTema.azulOscuro, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _horaEntradaDocController.text.isNotEmpty ? _horaEntradaDocController.text.substring(0, 5) : "08:00",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MiTema.blanco),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 8),
                    child: Text(
                      "SALIDA".toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  InkWell(
                    onTap: () => _seleccionarHoraRelojInteractivo(_horaSalidaDocController),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 100, 
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: MiTema.azulOscuro, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _horaSalidaDocController.text.isNotEmpty ? _horaSalidaDocController.text.substring(0, 5) : "18:00",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MiTema.blanco),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

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
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
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