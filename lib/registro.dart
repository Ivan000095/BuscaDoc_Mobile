import 'dart:io';
import 'dart:async';
import 'package:bootstrap_icons/bootstrap_icons.dart';
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

  final _contactoEmergenciaController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _padecimientosController = TextEditingController();
  final _habitosController = TextEditingController();

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
  
  // ✅ Variables para dropdowns de paciente
  String? _generoSeleccionado;
  String? _tipoSangreSeleccionado;
  
  // ✅ Listas de opciones según BD
  final List<String> _listaGeneros = ['Masculino', 'Femenino'];
  final List<String> _listaTiposSangre = [
    'Desconocido', 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-',
  ];
  
  // ✅ VALOR FIJO PARA PARENTESCO EN REGISTRO
  static const String _parentescoPropio = 'Expediente Propio';
  
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
      if(mounted) setState(() {});
    } catch (e) {
      print("Error cargando especialidades: $e");
    }

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
    _contactoEmergenciaController.dispose();
    _alergiasController.dispose();
    _padecimientosController.dispose();
    _habitosController.dispose();
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
        // Validación de tamaño: máximo 5MB
        final archivo = File(imagenSeleccionada.path);
        if (archivo.lengthSync() > 5 * 1024 * 1024) {
          UIUtils.showRoundedSnackBar(
            context, 
            'La imagen no debe superar los 5MB', 
            MiTema.rojoerror, 
            MiTema.blanco
          );
          return;
        }
        setState(() {
          _fotoPerfil = archivo;
        });
      }
    } catch (e) {
      print("Error al seleccionar foto: $e");
      if (mounted) {
        UIUtils.showRoundedSnackBar(
          context, 
          'Error al seleccionar la imagen', 
          MiTema.rojoerror, 
          MiTema.blanco
        );
      }
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    DateTime fechaInicial = DateTime.now().subtract(const Duration(days: 365 * 18));
    
    if (_fechaNacimientoController.text.isNotEmpty) {
      try {
        fechaInicial = DateTime.parse(_fechaNacimientoController.text);
      } catch (e) {
        // no me importa
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
    // ... (Tus validaciones existentes: email, password, etc.)

    // 1️⃣ Validar campos médicos
    if (_generoSeleccionado == null || _generoSeleccionado!.isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'Selecciona tu género', MiTema.rojoerror, MiTema.blanco);
      return;
    }

    setState(() => _estaCargando = true);

    // 2️⃣ Construir el Mapa de Datos
    Map<String, dynamic> datos = {
      // Datos del Usuario
      "name": _nombreController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
      "password_confirmation": _confirmPasswordController.text,
      "role": "paciente", // Fijo
      "f_nacimiento": _fechaNacimientoController.text,
      "latitud": _ubicacionDoctor.latitude.toString(), // Si tienes ubicación
      "longitud": _ubicacionDoctor.longitude.toString(),

      // --- DATOS DEL EXPEDIENTE MÉDICO ---
      // ✅ IMPORTANTE: Convertir a minúsculas para evitar el error de Postgres
      "genero": _generoSeleccionado?.toLowerCase(), 
      
      "parentesco": "Expediente Propio", // Valor fijo
      "tipo_sangre": _tipoSangreSeleccionado,
      "contacto_emergencia": _contactoEmergenciaController.text.trim(),
      
      // Campos opcionales (enviar solo si no están vacíos)
      "alergias": _alergiasController.text.trim().isEmpty ? null : _alergiasController.text.trim(),
      "padecimientos": _padecimientosController.text.trim().isEmpty ? null : _padecimientosController.text.trim(),
      "habitos": _habitosController.text.trim().isEmpty ? null : _habitosController.text.trim(),
    };

    // Filtrar nulls (opcional, pero recomendado)
    datos.removeWhere((key, value) => value == null);

    // 3️⃣ Enviar a la API
    var respuesta = await Usuario.registrar(datos, fotoPerfil: _fotoPerfil);

    setState(() => _estaCargando = false);

    // 4️⃣ Manejar respuesta
    if (respuesta['success']) {
      UIUtils.showRoundedSnackBar(context, '¡Registro exitoso! Ahora inicia sesión', MiTema.verde, MiTema.blanco);
      // Redirigir al Login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InicioSesion()));
    } else {
      UIUtils.showRoundedSnackBar(context, respuesta['message'], MiTema.rojoerror, MiTema.blanco);
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
                    
                    _campoTexto('Nombre Completo', _nombreController, icono: BootstrapIcons.person),
                    _campoTexto('Correo electrónico', _emailController, icono: BootstrapIcons.envelope, keyboardType: TextInputType.emailAddress),
                    _campoTexto('Contraseña', _passwordController, isPassword: true, icono: BootstrapIcons.lock),
                    _campoTexto('Confirmar contraseña', _confirmPasswordController, isPassword: true, icono: BootstrapIcons.shield_lock),
                    
                    _campoTexto(
                      'Fecha de Nacimiento', 
                      _fechaNacimientoController, 
                      icono: BootstrapIcons.calendar2,
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
                          :  Text(
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
                          child:  Text(
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

  // ✅ Widget reutilizable para dropdowns
  Widget _buildDropdownField({
    required String label,
    required IconData icono,
    required String? valorActual,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
    String hintText = 'Seleccionar...',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: MiTema.gris,
              borderRadius: BorderRadius.circular(50),
            ),
            child: DropdownButtonFormField<String>(
              value: opciones.contains(valorActual) ? valorActual : null,
              isExpanded: true,
              icon:  Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
              decoration: InputDecoration(
                prefixIcon: Icon(icono, color: MiTema.azulOscuro, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              style: TextStyle(
                fontSize: 14,
                color: MiTema.negro,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: MiTema.blanco,
              borderRadius: BorderRadius.circular(20),
              items: opciones.map((opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget para campos de texto multilínea
  Widget _buildTextArea({
    required String label,
    required String hintText,
    required TextEditingController controller,
    IconData? icono,
    int maxLines = 3,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: MiTema.gris,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                prefixIcon: icono != null ? Icon(icono, color: MiTema.azulOscuro, size: 20) : null,
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formularioPaciente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATOS MÉDICOS BÁSICOS', 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)
        ),
        const SizedBox(height: 16),
        
        // ✅ DROPDOWNS EN FILA (Género y Tipo de Sangre)
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: "Género",
                icono: Icons.person_outline,
                valorActual: _generoSeleccionado,
                opciones: _listaGeneros,
                onChanged: (valor) => setState(() => _generoSeleccionado = valor),
                hintText: 'Masculino',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: "Tipo de Sangre",
                icono: Icons.bloodtype_outlined,
                valorActual: _tipoSangreSeleccionado,
                opciones: _listaTiposSangre,
                onChanged: (valor) => setState(() => _tipoSangreSeleccionado = valor),
                hintText: 'Seleccione el Tipo de Sangre',
              ),
            ),
          ],
        ),
        
        // ✅ CAMPOS DE TEXTO MULTILÍNEA
        _buildTextArea(
          label: "Alergias",
          hintText: "Escriba que alergias tiene",
          controller: _alergiasController,
          icono: BootstrapIcons.capsule_pill,
          maxLines: 2,
        ),
        
        _buildTextArea(
          label: "Padecimientos Crónicos",
          hintText: "Diabetes, Hipertensión, etc.",
          controller: _padecimientosController,
          icono: BootstrapIcons.clipboard2_pulse,
          maxLines: 3,
        ),
        
        _buildTextArea(
          label: "Hábitos de Salud",
          hintText: "Ej: Ejercicio regular, fumador, etc.",
          controller: _habitosController,
          icono: Icons.favorite_outline,
          maxLines: 3,
        ),
        
        // ✅ CONTACTO DE EMERGENCIA
        _campoTexto(
          'Contacto de Emergencia', 
          _contactoEmergenciaController, 
          icono: BootstrapIcons.telephone,
          keyboardType: TextInputType.phone
        ),
        
        // ✅ PARENTESCO - VALOR FIJO (NO EDITABLE)
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MiTema.azulOscuro.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MiTema.azulOscuro.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: MiTema.azulOscuro, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parentesco',
                      style: TextStyle(
                        fontSize: 11,
                        color: MiTema.azulOscuro.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _parentescoPropio,  // ← Valor fijo mostrado
                      style: TextStyle(
                        fontSize: 14,
                        color: MiTema.azulOscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: MiTema.verde, size: 18),
            ],
          ),
        ),
        
        // ✅ NOTA INFORMATIVA
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Al registrarse, se creará automáticamente tu expediente médico personal.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formularioDoctor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DATOS DE TRABAJO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        
        // 🔥 DROPDOWN DE ESPECIALIDADES
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: _especialidadIdSeleccionada,
            icon:  Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
            decoration: InputDecoration(
              prefixIcon:  Icon(BootstrapIcons.heart_pulse, color: MiTema.azulOscuro, size: 20),
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

        _campoTexto('Cédula Profesional', _cedulaController, icono: BootstrapIcons.person_vcard),
        _campoTexto('Costo por consulta (\$)', _costoController, icono: BootstrapIcons.currency_dollar, keyboardType: TextInputType.number),
        _campoTexto('Idiomas (Ej. Español, Inglés)', _idiomasController, icono: BootstrapIcons.translate),
        _campoTexto('Descripción de su trabajo', _descDocController, icono: BootstrapIcons.file_earmark_text),
        
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