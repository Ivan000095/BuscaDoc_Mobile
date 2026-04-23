import 'dart:io';
import 'dart:async';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show TimeOfDay;
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
  final _descDocController = TextEditingController();
  final _idiomasController = TextEditingController();

  bool _estaCargando = false;
  File? _fotoPerfil;
  final ImagePicker _picker = ImagePicker();

  String _rolSeleccionado = 'paciente';

  String? _generoSeleccionado;
  String? _tipoSangreSeleccionado;
  final List<String> _listaGeneros = ['Masculino', 'Femenino'];
  final List<String> _listaTiposSangre = [
    'Desconocido', 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-',
  ];
  static const String _parentescoPropio = 'Expediente Propio';
  
  int? _especialidadIdSeleccionada;
  List<Especialidades> _listaEspecialidades = [];

  bool _habilitarCitasDoctor = false;
  String? _duracionCitaSeleccionada;
  final List<Map<String, String>> _duracionCitasOpciones = [
    {'valor': '15', 'etiqueta': '15 minutos'},
    {'valor': '20', 'etiqueta': '20 minutos'},
    {'valor': '30', 'etiqueta': '30 minutos'},
    {'valor': '45', 'etiqueta': '45 minutos'},
    {'valor': '60', 'etiqueta': '1 hora'},
  ];
  
  final List<Map<String, dynamic>> _listaHorarios = [];

  final List<Map<String, dynamic>> _diasSemana = [
    {'valor': 0, 'etiqueta': 'Domingo'},
    {'valor': 1, 'etiqueta': 'Lunes'},
    {'valor': 2, 'etiqueta': 'Martes'},
    {'valor': 3, 'etiqueta': 'Miércoles'},
    {'valor': 4, 'etiqueta': 'Jueves'},
    {'valor': 5, 'etiqueta': 'Viernes'},
    {'valor': 6, 'etiqueta': 'Sábado'},
  ];
  
  // 🔹 Ubicación
  LatLng _ubicacionDoctor = const LatLng(16.9060, -92.0934);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _duracionCitaSeleccionada = '30';
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
  Future<void> _confirmarYEliminar(int index) async {
    if (index < 0 || index >= _listaHorarios.length) return;
    
    final horario = _listaHorarios[index];
    final dia = _obtenerNombreDia(horario['dia']);
    
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: Text('¿Eliminar $dia ${horario['inicio']} - ${horario['fin']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: MiTema.rojoerror),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmado == true && mounted) {
      _eliminarHorario(index);
    }
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
        final archivo = File(imagenSeleccionada.path);
        if (archivo.lengthSync() > 5 * 1024 * 1024) {
          UIUtils.showRoundedSnackBar(
            context, 'La imagen no debe superar los 5MB', MiTema.rojoerror, MiTema.blanco);
          return;
        }
        setState(() => _fotoPerfil = archivo);
      }
    } catch (e) {
      print("Error al seleccionar foto: $e");
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, 'Error al seleccionar la imagen', MiTema.rojoerror, MiTema.blanco);
      }
    }
  }


  Future<void> _seleccionarFechaNacimiento() async {
    DateTime fechaInicial = DateTime.now().subtract(const Duration(days: 365 * 18));
    if (_fechaNacimientoController.text.isNotEmpty) {
      try {
        fechaInicial = DateTime.parse(_fechaNacimientoController.text);
      } catch (e) {}
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

  void _toggleHabilitarCitas(bool valor) {
    setState(() {
      _habilitarCitasDoctor = valor;
      
      if (valor) {
        _duracionCitaSeleccionada = '30';
        if (_listaHorarios.isEmpty) {
          final baseId = DateTime.now().millisecondsSinceEpoch;
          for (int dia = 1; dia <= 5; dia++) {
            _listaHorarios.add({
              'id': baseId + dia, 
              'dia': dia,
              'inicio': '09:00',
              'fin': '18:00',
            });
          }
        }
      } else {
        _duracionCitaSeleccionada = null;
      }
    });
  }

  // Agregar horario con time picker simple (nativo de Flutter)
  void _agregarHorario() {
    int? diaSeleccionado;
    TimeOfDay? horaInicio = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay? horaFin = const TimeOfDay(hour: 18, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Horario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown de día
                DropdownButtonFormField<int>(
                  value: diaSeleccionado,
                  decoration: const InputDecoration(labelText: 'Día de la semana'),
                  items: _diasSemana.map((dia) {
                    return DropdownMenuItem<int>(
                      value: dia['valor'] as int,
                      child: Text(dia['etiqueta'] as String),
                    );
                  }).toList(),
                  onChanged: (valor) => setDialogState(() => diaSeleccionado = valor),
                ),
                const SizedBox(height: 16),
                
                // Hora de inicio (picker nativo)
                ListTile(
                  title: const Text('Hora de inicio'),
                  subtitle: Text(horaInicio != null 
                    ? '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}' 
                    : 'Seleccionar'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: horaInicio ?? const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) {
                      setDialogState(() => horaInicio = picked);
                    }
                  },
                ),
                
                // Hora de fin (picker nativo)
                ListTile(
                  title: const Text('Hora de fin'),
                  subtitle: Text(horaFin != null 
                    ? '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}' 
                    : 'Seleccionar'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: horaFin ?? const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (picked != null) {
                      setDialogState(() => horaFin = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                if (diaSeleccionado == null || horaInicio == null || horaFin == null) {
                  UIUtils.showRoundedSnackBar(context, 'Completa todos los campos', MiTema.rojoerror, MiTema.blanco);
                  return;
                }
                
                // Validar que fin > inicio
                if (horaFin!.hour < horaInicio!.hour || 
                    (horaFin!.hour == horaInicio!.hour && horaFin!.minute <= horaInicio!.minute)) {
                  UIUtils.showRoundedSnackBar(context, 'La hora de fin debe ser después de la hora de inicio', MiTema.rojoerror, MiTema.blanco);
                  return;
                }

                setState(() {
                  _listaHorarios.add({
                    'id': DateTime.now().millisecondsSinceEpoch + _listaHorarios.length,
                    'dia': diaSeleccionado,
                    'inicio': '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}',
                    'fin': '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}',
                  });
                  // Ordenar por día y hora
                  _listaHorarios.sort((a, b) {
                    int cmp = a['dia'].compareTo(b['dia']);
                    return cmp == 0 ? a['inicio'].compareTo(b['inicio']) : cmp;
                  });
                });
                
                Navigator.pop(context);
                UIUtils.showRoundedSnackBar(context, 'Horario agregado', MiTema.verde, MiTema.blanco);
              },
              style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro),
              child: const Text('AGREGAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
// Eliminar horario por índice (simple y directo)
void _eliminarHorario(int index) {
  if (index >= 0 && index < _listaHorarios.length) {
    setState(() {
      _listaHorarios.removeAt(index);
    });
    if (mounted) {
      UIUtils.showRoundedSnackBar(context, 'Horario eliminado', MiTema.azulOscuro, MiTema.blanco);
    }
  }
}

  //Obtener nombre del día
  String _obtenerNombreDia(int valor) {
    return _diasSemana.firstWhere((d) => d['valor'] == valor, orElse: () => {'etiqueta': ''})['etiqueta'];
  }

  // Procesar registro
  Future<void> _procesarRegistro() async {
    // Validaciones básicas
    if (_nombreController.text.trim().isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'El nombre es obligatorio', MiTema.rojoerror, MiTema.blanco);
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'El email es obligatorio', MiTema.rojoerror, MiTema.blanco);
      return;
    }
    if (_passwordController.text.isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'La contraseña es obligatoria', MiTema.rojoerror, MiTema.blanco);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      UIUtils.showRoundedSnackBar(context, 'Las contraseñas no coinciden', MiTema.rojoerror, MiTema.blanco);
      return;
    }
    if (_fechaNacimientoController.text.isEmpty) {
      UIUtils.showRoundedSnackBar(context, 'Selecciona tu fecha de nacimiento', MiTema.rojoerror, MiTema.blanco);
      return;
    }

    if (_rolSeleccionado == 'paciente') {
      if (_generoSeleccionado == null || _generoSeleccionado!.isEmpty) {
        UIUtils.showRoundedSnackBar(context, 'Selecciona tu género', MiTema.rojoerror, MiTema.blanco);
        return;
      }
    }

    if (_rolSeleccionado == 'doctor') {
      if (_cedulaController.text.trim().isEmpty) {
        UIUtils.showRoundedSnackBar(context, 'La cédula profesional es obligatoria', MiTema.rojoerror, MiTema.blanco);
        return;
      }
      if (_costoController.text.trim().isEmpty) {
        UIUtils.showRoundedSnackBar(context, 'El costo por consulta es obligatorio', MiTema.rojoerror, MiTema.blanco);
        return;
      }
      if (_especialidadIdSeleccionada == null) {
        UIUtils.showRoundedSnackBar(context, 'Selecciona al menos una especialidad', MiTema.rojoerror, MiTema.blanco);
        return;
      }
      if (_habilitarCitasDoctor && _listaHorarios.isEmpty) {
        UIUtils.showRoundedSnackBar(context, 'Agrega al menos un horario de atención', MiTema.rojoerror, MiTema.blanco);
        return;
      }
    }

    setState(() => _estaCargando = true);
    Map<String, dynamic> datos = {
      "name": _nombreController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
      "password_confirmation": _confirmPasswordController.text,
      "role": _rolSeleccionado,
      "f_nacimiento": _fechaNacimientoController.text,
      "latitud": _ubicacionDoctor.latitude.toString(),
      "longitud": _ubicacionDoctor.longitude.toString(),
    };

    if (_rolSeleccionado == 'paciente') {
      datos.addAll({
        "genero": _generoSeleccionado?.toLowerCase(),
        "tipo_sangre": _tipoSangreSeleccionado,
        "contacto_emergencia": _contactoEmergenciaController.text.trim(),
        "alergias": _alergiasController.text.trim().isEmpty ? null : _alergiasController.text.trim(),
        "padecimientos": _padecimientosController.text.trim().isEmpty ? null : _padecimientosController.text.trim(),
        "habitos": _habitosController.text.trim().isEmpty ? null : _habitosController.text.trim(),
        "parentesco": _parentescoPropio,
      });
    } 
    else if (_rolSeleccionado == 'doctor') {
      List<Map<String, dynamic>> horariosParaEnviar = _listaHorarios.map((h) {
        return {
          'dia': h['dia'],
          'inicio': h['inicio'],
          'fin': h['fin'],
        };
      }).toList();

      datos.addAll({
        "cedula": _cedulaController.text.trim(),
        "costo": _costoController.text.trim(),
        "duracion_cita": _habilitarCitasDoctor ? (_duracionCitaSeleccionada ?? '30') : null,
        "citas": _habilitarCitasDoctor.toString(),
        "descripcion_doc": _descDocController.text.trim().isEmpty ? null : _descDocController.text.trim(),
        "idiomas": _idiomasController.text.trim().isEmpty ? null : _idiomasController.text.trim(),
        "especialidades": [_especialidadIdSeleccionada],
        "horarios": _habilitarCitasDoctor ? horariosParaEnviar : [],
      });
    }

    datos.removeWhere((key, value) => value == null);
    var respuesta = await Usuario.registrar(datos, fotoPerfil: _fotoPerfil);
    setState(() => _estaCargando = false);

    if (respuesta['success']) {
      UIUtils.showRoundedSnackBar(context, '¡Registro exitoso! Bienvenido ${_nombreController.text}', MiTema.verde, MiTema.blanco);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InicioSesion()));
    } else {
      if (respuesta['errors'] != null) {
        String errores = '';
        (respuesta['errors'] as Map).forEach((key, value) {
          if (value is List) errores += '${_traducirCampo(key)}: ${value.join(', ')}\n';
        });
        UIUtils.showRoundedSnackBar(context, errores, MiTema.rojoerror, MiTema.blanco);
      } else {
        UIUtils.showRoundedSnackBar(context, respuesta['message'], MiTema.rojoerror, MiTema.blanco);
      }
    }
  }

  String _traducirCampo(String campo) {
    switch (campo) {
      case 'name': return 'Nombre';
      case 'email': return 'Correo electrónico';
      case 'password': return 'Contraseña';
      case 'cedula': return 'Cédula profesional';
      case 'costo': return 'Costo por consulta';
      case 'duracion_cita': return 'Duración de cita';
      case 'especialidades': return 'Especialidades';
      case 'horarios': return 'Horarios';
      case 'genero': return 'Género';
      case 'f_nacimiento': return 'Fecha de nacimiento';
      default: return campo;
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
              Image.asset('assets/logon.png', width: 200, height: 120, fit: BoxFit.contain),
              const SizedBox(height: 10),
              const Text('"Un lugar para todas tus necesidades"', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF666666), fontStyle: FontStyle.italic)),
              const SizedBox(height: 30),
              
              Container(
                decoration: BoxDecoration(color: MiTema.blanco, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Únete a BuscaDoc', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF000000))),
                    const SizedBox(height: 24),

                    Center(
                      child: GestureDetector(
                        onTap: _seleccionarFoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200, border: Border.all(color: MiTema.azulOscuro, width: 3), image: _fotoPerfil != null ? DecorationImage(image: FileImage(_fotoPerfil!), fit: BoxFit.cover) : null),
                              child: _fotoPerfil == null ? Icon(Icons.person, size: 60, color: Colors.grey.shade400) : null,
                            ),
                            Positioned(bottom: 0, right: 4, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: MiTema.azulOscuro, shape: BoxShape.circle, border: Border.all(color: MiTema.blanco, width: 2)), child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Toca para subir una foto", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 24),
                    
                    _campoTexto('Nombre Completo', _nombreController, icono: BootstrapIcons.person),
                    _campoTexto('Correo electrónico', _emailController, icono: BootstrapIcons.envelope, keyboardType: TextInputType.emailAddress),
                    _campoTexto('Contraseña', _passwordController, isPassword: true, icono: BootstrapIcons.lock),
                    _campoTexto('Confirmar contraseña', _confirmPasswordController, isPassword: true, icono: BootstrapIcons.shield_lock),
                    _campoTexto('Fecha de Nacimiento', _fechaNacimientoController, icono: BootstrapIcons.calendar2, readOnly: true, onTap: _seleccionarFechaNacimiento),
                    
                    const Divider(height: 40),
                    const Text('TIPO DE PERFIL', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 10),
                    
                    DropdownButtonFormField<String>(
                      value: _rolSeleccionado,
                      isExpanded: true,
                      decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, prefixIcon: Icon(Icons.badge_outlined, color: MiTema.azulOscuro), border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      items: const [
                        DropdownMenuItem(value: 'paciente', child: Text('Paciente (Busco atención)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'doctor', child: Text('Doctor (Ofrezco servicios)', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (String? nuevoValor) {
                        if (nuevoValor != null) setState(() => _rolSeleccionado = nuevoValor);
                      },
                    ),

                    const SizedBox(height: 24),
                    if (_rolSeleccionado == 'paciente') _formularioPaciente(),
                    if (_rolSeleccionado == 'doctor') _formularioDoctor(),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _estaCargando ? null : _procesarRegistro,
                      style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), elevation: 5),
                      child: _estaCargando ? const CircularProgressIndicator(color: Colors.white) : Text('Registrarme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MiTema.blanco, letterSpacing: 1.2)),
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? ', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InicioSesion())),
                          child: Text('Inicia sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)),
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
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: MiTema.azulOscuro, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required IconData icono, required String? valorActual, required List<String> opciones, required ValueChanged<String?> onChanged, String hintText = 'Seleccionar...'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1))),
        Container(
          decoration: BoxDecoration(color: MiTema.gris, borderRadius: BorderRadius.circular(50)),
          child: DropdownButtonFormField<String>(
            value: opciones.contains(valorActual) ? valorActual : null,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
            decoration: InputDecoration(prefixIcon: Icon(icono, color: MiTema.azulOscuro, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), hintText: hintText, hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            style: TextStyle(fontSize: 14, color: MiTema.negro, fontWeight: FontWeight.w500),
            dropdownColor: MiTema.blanco,
            borderRadius: BorderRadius.circular(20),
            items: opciones.map((opcion) => DropdownMenuItem<String>(value: opcion, child: Text(opcion))).toList(),
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }

  Widget _buildTextArea({required String label, required String hintText, required TextEditingController controller, IconData? icono, int maxLines = 3}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1))),
        Container(
          decoration: BoxDecoration(color: MiTema.gris, borderRadius: BorderRadius.circular(20)),
          child: TextFormField(controller: controller, maxLines: maxLines, decoration: InputDecoration(prefixIcon: icono != null ? Icon(icono, color: MiTema.azulOscuro, size: 20) : null, filled: true, fillColor: Colors.transparent, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), hintText: hintText, hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500))),
        ),
      ]),
    );
  }

  Widget _formularioPaciente() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DATOS MÉDICOS BÁSICOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _buildDropdownField(label: "Género", icono: Icons.person_outline, valorActual: _generoSeleccionado, opciones: _listaGeneros, onChanged: (valor) => setState(() => _generoSeleccionado = valor), hintText: 'Masculino')),
        const SizedBox(width: 12),
        Expanded(child: _buildDropdownField(label: "Tipo de Sangre", icono: Icons.bloodtype_outlined, valorActual: _tipoSangreSeleccionado, opciones: _listaTiposSangre, onChanged: (valor) => setState(() => _tipoSangreSeleccionado = valor), hintText: 'Seleccione el Tipo de Sangre')),
      ]),
      _buildTextArea(label: "Alergias", hintText: "Escriba que alergias tiene", controller: _alergiasController, icono: BootstrapIcons.capsule_pill, maxLines: 2),
      _buildTextArea(label: "Padecimientos Crónicos", hintText: "Diabetes, Hipertensión, etc.", controller: _padecimientosController, icono: BootstrapIcons.clipboard2_pulse, maxLines: 3),
      _buildTextArea(label: "Hábitos de Salud", hintText: "Ej: Ejercicio regular, fumador, etc.", controller: _habitosController, icono: Icons.favorite_outline, maxLines: 3),
      _campoTexto('Contacto de Emergencia', _contactoEmergenciaController, icono: BootstrapIcons.telephone, keyboardType: TextInputType.phone),
      Container(margin: const EdgeInsets.only(top: 10, bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: MiTema.azulOscuro.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: MiTema.azulOscuro.withOpacity(0.3))), child: Row(children: [Icon(Icons.lock_outline, color: MiTema.azulOscuro, size: 18), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Parentesco', style: TextStyle(fontSize: 11, color: MiTema.azulOscuro.withOpacity(0.7), fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(_parentescoPropio, style: TextStyle(fontSize: 14, color: MiTema.azulOscuro, fontWeight: FontWeight.w600))])), Icon(Icons.check_circle, color: MiTema.verde, size: 18)])),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18), const SizedBox(width: 8), Expanded(child: Text('Al registrarse, se creará automáticamente tu expediente médico personal.', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)))])),
    ]);
  }

  Widget _formularioDoctor() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DATOS DE TRABAJO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 16),
      
      Container(margin: const EdgeInsets.only(bottom: 16), child: DropdownButtonFormField<int>(
        isExpanded: true, value: _especialidadIdSeleccionada, icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
        decoration: InputDecoration(prefixIcon: Icon(BootstrapIcons.heart_pulse, color: MiTema.azulOscuro, size: 20), labelText: "Especialidad", labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
        items: _listaEspecialidades.isEmpty ? null : _listaEspecialidades.map((esp) => DropdownMenuItem<int>(value: esp.id, child: Text(esp.nombre, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: _listaEspecialidades.isEmpty ? null : (int? nuevoId) => setState(() => _especialidadIdSeleccionada = nuevoId),
      )),

      _campoTexto('Cédula Profesional', _cedulaController, icono: BootstrapIcons.person_vcard),
      _campoTexto('Costo por consulta (\$)', _costoController, icono: BootstrapIcons.currency_dollar, keyboardType: TextInputType.number),
      _campoTexto('Idiomas (Ej. Español, Inglés)', _idiomasController, icono: BootstrapIcons.translate),
      _campoTexto('Descripción de su trabajo', _descDocController, icono: BootstrapIcons.file_earmark_text),
      
      Container(margin: const EdgeInsets.only(bottom: 16, top: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)), child: Row(children: [
        Icon(Icons.event_available, color: MiTema.azulOscuro, size: 24), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('¿Habilitar recepción de citas en línea?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
          const SizedBox(height: 2),
          Text(_habilitarCitasDoctor ? 'Los pacientes podrán agendar citas' : 'No se recibirán citas en línea', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ])),
        Switch(
          value: _habilitarCitasDoctor,
          onChanged: _toggleHabilitarCitas,
          activeColor: MiTema.verde,
          inactiveThumbColor: Colors.grey,
        ),
      ])),

      if (_habilitarCitasDoctor) Container(margin: const EdgeInsets.only(bottom: 16), child: DropdownButtonFormField<String>(
        value: _duracionCitaSeleccionada, isExpanded: true,
        decoration: InputDecoration(prefixIcon: Icon(Icons.access_time, color: MiTema.azulOscuro, size: 20), labelText: "Duración promedio de cada cita", labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
        items: _duracionCitasOpciones.map((op) => DropdownMenuItem<String>(
          value: op['valor'] as String,
          child: Text(op['etiqueta'] as String),
        )).toList(),
        onChanged: (String? valor) => setState(() => _duracionCitaSeleccionada = valor),
      )),

      if (_habilitarCitasDoctor) ...[
        const SizedBox(height: 24),
        Row(children: [
          const Text('HORARIOS DE ATENCIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Spacer(),
          TextButton.icon(
            onPressed: _agregarHorario,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Agregar horario'),
            style: TextButton.styleFrom(foregroundColor: MiTema.azulOscuro),
          ),
        ]),
        const SizedBox(height: 8),
if (_listaHorarios.isEmpty)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Agrega los días y horarios en que trabajas. Puedes tener múltiples bloques.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ),
      ],
    ),
  )
else
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _listaHorarios.length,
    itemBuilder: (context, index) {
      final horario = _listaHorarios[index];
      
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: MiTema.azulOscuro,
            child: Text(
              _obtenerNombreDia(horario['dia']).substring(0, 3).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            _obtenerNombreDia(horario['dia']),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '${horario['inicio']} - ${horario['fin']}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
            onPressed: () => _confirmarYEliminar(index),
            tooltip: 'Eliminar este horario',
          ),
        ),
      );
    },
  ),
      ],

      const SizedBox(height: 24),
      const Text('UBICACIÓN DEL CONSULTORIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 8),
      const Text('Mueve el mapa y toca para fijar la ubicación exacta:', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 10),
      Container(height: 220, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: MiTema.azulOscuro.withOpacity(0.3), width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: GoogleMap(
        onMapCreated: (GoogleMapController controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(target: _ubicacionDoctor, zoom: 15.0),
        onTap: (LatLng nuevaPosicion) => setState(() => _ubicacionDoctor = nuevaPosicion),
        markers: {Marker(markerId: const MarkerId('pin_consultorio'), position: _ubicacionDoctor, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue))},
        myLocationEnabled: true, myLocationButtonEnabled: true, mapToolbarEnabled: false, zoomControlsEnabled: false,
      ))),
    ]);
  }
}