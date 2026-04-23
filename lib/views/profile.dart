import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buscadoc_mobile/model/especialidad.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';

class EditarPerfil extends StatefulWidget {
  final String nombreActual;
  final String correoActual;
  final String fotoActual;

  const EditarPerfil({
    super.key,
    required this.nombreActual,
    required this.correoActual,
    required this.fotoActual,
  });

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _descripcionController;
  late TextEditingController _cedulaController;
  late TextEditingController _costosController;
  late TextEditingController _idiomasController;
  late List<Especialidades> _especialidades = [];
  int? _espIdSeleccionada;
  String _especialidadActual = "";
  String _roleCache = '';
  String _emailOriginal = '';

  bool _guardando = false;
  bool _cargandoPerfil = true;
  Map<String, dynamic>? _datosPerfil;

  bool _habilitarCitasDoctor = false;
  String? _duracionCitaSeleccionada;
  final List<Map<String, dynamic>> _listaHorarios = [];
  int _horarioCounter = 0;
  
  final List<Map<String, String>> _duracionCitasOpciones = [
    {'valor': '15', 'etiqueta': '15 minutos'},
    {'valor': '20', 'etiqueta': '20 minutos'},
    {'valor': '30', 'etiqueta': '30 minutos'},
    {'valor': '45', 'etiqueta': '45 minutos'},
    {'valor': '60', 'etiqueta': '1 hora'},
  ];
  
  final List<Map<String, dynamic>> _diasSemana = [
    {'valor': 0, 'etiqueta': 'Domingo'},
    {'valor': 1, 'etiqueta': 'Lunes'},
    {'valor': 2, 'etiqueta': 'Martes'},
    {'valor': 3, 'etiqueta': 'Miércoles'},
    {'valor': 4, 'etiqueta': 'Jueves'},
    {'valor': 5, 'etiqueta': 'Viernes'},
    {'valor': 6, 'etiqueta': 'Sábado'},
  ];

  @override
  void initState() {
    super.initState();
    _duracionCitaSeleccionada = '30';
    _inicializarControllers();
    _cargarDatosPerfil();
  }

  void _inicializarControllers() {
    _nombreController = TextEditingController(text: widget.nombreActual);
    _correoController = TextEditingController(text: widget.correoActual);
    
    _descripcionController = TextEditingController();
    _cedulaController = TextEditingController();
    _costosController = TextEditingController();
    _idiomasController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    _cedulaController.dispose();
    _costosController.dispose();
    _idiomasController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final idString = prefs.getString('id');

      if (token == null || idString == null) {
        setState(() => _cargandoPerfil = false);
        return;
      }

      final myId = int.parse(idString);
      final response = await Usuario.show(token, myId);

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _datosPerfil = response['data'];
          _roleCache = _datosPerfil?['role']?.toString() ?? '';
          _emailOriginal = _datosPerfil?['email']?.toString() ?? '';

          _nombreController.text = _datosPerfil?['name'] ?? widget.nombreActual;
          _correoController.text = _datosPerfil?['email'] ?? widget.correoActual;

          if (_roleCache == 'doctor') {
            _cargarDatosDoctor();
          }

          _cargandoPerfil = false;
        });
      } else {
        UIUtils.showRoundedSnackBar(context, response['message'], MiTema.rojoerror, MiTema.blanco);
        setState(() => _cargandoPerfil = false);
      }
    } catch (e) {
      print('❌ Error en _cargarDatosPerfil: $e');
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, 'Error al cargar perfil', MiTema.rojoerror, MiTema.blanco);
      }
      setState(() => _cargandoPerfil = false);
    }
  }

  void _cargarDatosDoctor() {
    _especialidadActual = _datosPerfil?['especialidad'] ?? '';
    if (_especialidadActual.isNotEmpty && _especialidades.isEmpty) {
      Especialidades.all().then((lista) {
        if (mounted) {
          setState(() {
            _especialidades = lista;
            _seleccionarEspecialidadGuardada();
          });
        }
      });
    } else if (_especialidades.isNotEmpty) {
      _seleccionarEspecialidadGuardada();
    }

    _descripcionController.text = _datosPerfil?['descripcion']?.toString() 
                               ?? _datosPerfil?['descripcion_doc']?.toString() 
                               ?? '';
    _cedulaController.text = _datosPerfil?['cedula']?.toString() ?? '';
    
    _idiomasController.text = _datosPerfil?['idiomas']?.toString() 
                           ?? _datosPerfil?['idioma']?.toString() 
                           ?? '';

    final costoRaw = _datosPerfil?['costo'] ?? _datosPerfil?['costos'] ?? 0;
    _costosController.text = costoRaw.toString().replaceAll(RegExp(r'[^\d.]'), '');
    
    final citasValue = _datosPerfil?['citas'];
    _habilitarCitasDoctor = citasValue == true || citasValue == 1 || citasValue == '1';
    
    final duracion = _datosPerfil?['duracion_cita'];
    if (duracion != null) {
      _duracionCitaSeleccionada = duracion.toString();
    }
    
    final horariosData = _datosPerfil?['horarios'] 
                      ?? _datosPerfil?['disponibilidades'] 
                      ?? _datosPerfil?['schedule']
                      ?? [];
    
    if (horariosData is List && horariosData.isNotEmpty) {
      for (var h in horariosData) {
        if (h is Map) {
          _listaHorarios.add({
            'id': _horarioCounter++,
            'dia': h['dia'] ?? h['dia_semana'] ?? 1,
            'inicio': _formatoHoraParaGuardar(h['inicio'] ?? h['hora_inicio']),
            'fin': _formatoHoraParaGuardar(h['fin'] ?? h['hora_fin']),
          });
        }
      }
      _listaHorarios.sort((a, b) {
        int cmp = (a['dia'] as int).compareTo(b['dia'] as int);
        return cmp == 0 ? (a['inicio'] as String).compareTo(b['inicio'] as String) : cmp;
      });
    }
  }

  void _seleccionarEspecialidadGuardada() {
    if (_especialidades.isEmpty) return;
    final nombreBuscado = _especialidadActual.split(',').first.trim().toLowerCase();
    try {
      final encontrada = _especialidades.firstWhere(
        (esp) => esp.nombre.trim().toLowerCase() == nombreBuscado,
      );
      _espIdSeleccionada = encontrada.id;
    } catch (_) {
      _espIdSeleccionada = null;
    }
  }

String _formatoHoraParaGuardar(dynamic horaRaw) {
  if (horaRaw == null) return '09:00';
  final horaStr = horaRaw.toString().trim();
  if (horaStr.isEmpty) return '09:00';
  
  if (horaStr.split(':').length == 3) {
    final partes = horaStr.split(':');
    return '${partes[0]}:${partes[1]}'; 
  }
  
  if (horaStr.split(':').length == 2) {
    return horaStr;
  }

  final hora = int.tryParse(horaStr);
  if (hora != null) {
    return '${hora.toString().padLeft(2, '0')}:00';
  }
  
  return '09:00';
}

  String _formatoHoraParaUI(dynamic horaRaw) {
    if (horaRaw == null) return '09:00';
    final horaStr = horaRaw.toString().trim();
    final partes = horaStr.split(':');
    if (partes.isNotEmpty) {
      final hora = int.tryParse(partes[0]);
      final min = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
      return '${hora.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
    }
    return '09:00';
  }

  Future<TimeOfDay?> _selectTimeNative(BuildContext context, TimeOfDay initial) async {
    return await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
           data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: MiTema.azulOscuro, onPrimary: MiTema.blanco),
          ),
          child: child!,
        );
      },
    );
  }

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
                DropdownButtonFormField<int>(
                  value: diaSeleccionado,
                  decoration: const InputDecoration(labelText: 'Día de la semana'),
                  items: _diasSemana.map((dia) => DropdownMenuItem<int>(
                    value: dia['valor'] as int,
                    child: Text(dia['etiqueta'] as String),
                  )).toList(),
                  onChanged: (valor) => setDialogState(() => diaSeleccionado = valor),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  title: const Text('Hora de inicio'),
                  subtitle: Text(horaInicio != null 
                    ? '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}' 
                    : 'Seleccionar'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await _selectTimeNative(context, horaInicio!);
                    if (picked != null && mounted) {
                      setDialogState(() => horaInicio = picked);
                    }
                  },
                ),
                
                ListTile(
                  title: const Text('Hora de fin'),
                  subtitle: Text(horaFin != null 
                    ? '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}' 
                    : 'Seleccionar'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await _selectTimeNative(context, horaFin!);
                    if (picked != null && mounted) {
                      setDialogState(() => horaFin = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () {
                if (diaSeleccionado == null || horaInicio == null || horaFin == null) {
                  UIUtils.showRoundedSnackBar(context, 'Completa todos los campos', MiTema.rojoerror, MiTema.blanco);
                  return;
                }
                if (horaFin!.hour < horaInicio!.hour || (horaFin!.hour == horaInicio!.hour && horaFin!.minute <= horaInicio!.minute)) {
                  UIUtils.showRoundedSnackBar(context, 'La hora de fin debe ser después de la hora de inicio', MiTema.rojoerror, MiTema.blanco);
                  return;
                }

                setState(() {
                  _listaHorarios.add({
                    'id': _horarioCounter++,
                    'dia': diaSeleccionado,
                      'inicio': '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}',
                      'fin': '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}',
                  });
                  _listaHorarios.sort((a, b) {
                    int cmp = (a['dia'] as int).compareTo(b['dia'] as int);
                    return cmp == 0 ? (a['inicio'] as String).compareTo(b['inicio'] as String) : cmp;
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

  Future<void> _confirmarYEliminar(int index) async {
    if (index < 0 || index >= _listaHorarios.length) return;
    final horario = _listaHorarios[index];
    final dia = _diasSemana.firstWhere((d) => d['valor'] == horario['dia'], orElse: () => {'etiqueta': ''})['etiqueta'];
    
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: Text('¿Eliminar $dia ${horario['inicio'].substring(0, 5)} - ${horario['fin'].substring(0, 5)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: MiTema.rojoerror),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmado == true && mounted) {
      setState(() => _listaHorarios.removeAt(index));
      UIUtils.showRoundedSnackBar(context, 'Horario eliminado', MiTema.azulOscuro, MiTema.blanco);
    }
  }

  String _obtenerNombreDia(int valor) {
    return _diasSemana.firstWhere((d) => d['valor'] == valor, orElse: () => {'etiqueta': ''})['etiqueta'];
  }

  Future<String?> _pedirContrasenaActual() async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verificar identidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa tu contraseña actual para cambiar el email:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro),
            child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    return result == true ? controller.text : null;
  }

  Future<void> _save() async {
    if (_roleCache == 'doctor' && _espIdSeleccionada == null) {
      if (mounted) UIUtils.showRoundedSnackBar(context, "Selecciona tu especialidad", MiTema.rojoerror, MiTema.blanco);
      return;
    }
    
    if (_roleCache == 'doctor' && _habilitarCitasDoctor && _listaHorarios.isEmpty) {
      if (mounted) UIUtils.showRoundedSnackBar(context, "Agrega al menos un horario de atención", MiTema.rojoerror, MiTema.blanco);
      return;
    }
    
    if (!mounted) return;
    setState(() => _guardando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final idString = prefs.getString('id');

      if (token == null || idString == null) throw Exception('Sesión inválida');
      final myId = int.parse(idString);

      List<Map<String, dynamic>>? horariosParaEnviar;
      if (_roleCache == 'doctor' && _habilitarCitasDoctor) {
        horariosParaEnviar = _listaHorarios.map((h) => {
          'dia': h['dia'],
          'inicio': h['inicio'],
          'fin': h['fin'],
        }).toList();
      }

      final emailNuevo = _correoController.text.trim();
      final emailCambio = _emailOriginal != emailNuevo;
      
      String? passwordActual;
      if (emailCambio) {
        passwordActual = await _pedirContrasenaActual();
        if (passwordActual == null || passwordActual.isEmpty) {
          setState(() => _guardando = false);
          UIUtils.showRoundedSnackBar(
            context, 
            'Se requiere contraseña actual para cambiar el email', 
            MiTema.rojoerror, 
            MiTema.blanco
          );
          return;
        }
      }

      final response = await Usuario.updateProfile(
        token: token,
        userId: myId,
        role: _roleCache,
        name: _nombreController.text.trim(),
        email: emailCambio ? emailNuevo : null,
        currentPassword: passwordActual,
        cedula: _roleCache == 'doctor' ? _cedulaController.text.trim() : null,
        costo: _roleCache == 'doctor' ? (num.tryParse(_costosController.text.trim()) ?? 0) : null,
        duracionCita: _roleCache == 'doctor' && _habilitarCitasDoctor 
            ? (int.tryParse(_duracionCitaSeleccionada ?? '30') ?? 30) 
            : null,
        citas: _roleCache == 'doctor' ? _habilitarCitasDoctor : null,
        descripcionDoc: _roleCache == 'doctor' ? _descripcionController.text.trim() : null,
        idiomas: _roleCache == 'doctor' ? _idiomasController.text.trim() : null,
        especialidades: _roleCache == 'doctor' && _espIdSeleccionada != null 
            ? [_espIdSeleccionada!] 
            : null,
        horarios: horariosParaEnviar,
      );
      
      if (!mounted) return;
      setState(() => _guardando = false);

      if (response['success']) {
        await prefs.setString('userName', _nombreController.text.trim());
        UIUtils.showRoundedSnackBar(context, response['message'], MiTema.verde, MiTema.blanco);
        Navigator.pop(context, true);
      } else {
        String msg = response['message'];
        final errs = response['errors'];
        if (errs is Map && errs.isNotEmpty) {
          msg = errs.values.first?.first ?? msg;
        }
        UIUtils.showRoundedSnackBar(context, msg, MiTema.rojoerror, MiTema.blanco);
      }
    } catch (e) {
      print('❌ Error en _save: $e');
      if (mounted) {
        setState(() => _guardando = false);
        UIUtils.showRoundedSnackBar(context, 'Error: $e', MiTema.rojoerror, MiTema.blanco);
      }
    }
  }

  Future<void> _confirmarEliminacion() async {
    if (!mounted) return;
    
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: MiTema.rojoerror, size: 28),
          const SizedBox(width: 10),
          const Text("¿Eliminar Cuenta?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
        content: const Text("Esta acción es irreversible. ¿Estás seguro?", style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MiTema.rojoerror),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sí, eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final idString = prefs.getString('id');
      
      if (token != null && idString != null) {
        final response = await Usuario.deleteAccount(token, int.parse(idString));
        
        if (!mounted) return;
        setState(() => _guardando = false);

        if (response['success']) {
          await prefs.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const InicioSesion()),
            (_) => false,
          );
        } else {
          UIUtils.showRoundedSnackBar(context, response['message'], MiTema.rojoerror, MiTema.blanco);
        }
      }
    } catch (e) {
      print('❌ Error al eliminar: $e');
      if (mounted) {
        setState(() => _guardando = false);
        UIUtils.showRoundedSnackBar(context, 'Error: $e', MiTema.rojoerror, MiTema.blanco);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urlFinal = widget.fotoActual.isNotEmpty
        ? (widget.fotoActual.startsWith('http') ? widget.fotoActual : '${Globals.webUrl}/storage/${widget.fotoActual}')
        : '';

    return Scaffold(
      backgroundColor: MiTema.gris,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Editar Perfil", style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: MiTema.azulOscuro), onPressed: () => Navigator.pop(context)),
      ),
      body: _cargandoPerfil
        ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(children: [
              Center(
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: urlFinal.isNotEmpty
                        ? Image.network(urlFinal, fit: BoxFit.cover, width: 130, height: 130, errorBuilder: (_, __, ___) => _iconoFallback())
                        : _iconoFallback(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionCard(title: "Información General", icon: Icons.person, children: [
                _buildTextField(label: "Nombre completo", icono: Icons.person_outline, controller: _nombreController),
                const SizedBox(height: 15),
                _buildTextField(
                  label: "Correo electrónico",
                  icono: Icons.email_outlined,
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  opacity: 0.5,
                ),
              ]),
              const SizedBox(height: 20),

              if (_roleCache == 'doctor') _buildDoctorSection(),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), elevation: 5),
                  onPressed: _guardando ? null : _save,
                  child: _guardando
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: MiTema.blanco, strokeWidth: 2))
                      : const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: MiTema.rojoerror, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                  onPressed: _guardando ? null : _confirmarEliminacion,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.delete_forever, color: MiTema.rojoerror),
                    const SizedBox(width: 8),
                    Text("Eliminar mi cuenta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MiTema.rojoerror)),
                  ]),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
    );
  }

  Widget _buildDoctorSection() {
    return _buildSectionCard(title: "Perfil Profesional", icon: Icons.medical_information_outlined, children: [
      _buildDropdownFieldEspecialidades(),
      const SizedBox(height: 15),
      _buildTextField(label: "Cédula Profesional", icono: Icons.verified_outlined, controller: _cedulaController, hintText: "Ej: MD-12345-CHI"),
      const SizedBox(height: 15),
      _buildTextField(label: "Costo Consulta (\$)", icono: Icons.attach_money, controller: _costosController, keyboardType: TextInputType.number, hintText: "Ej: 450"),
      const SizedBox(height: 15),
      _buildTextField(label: "Idiomas", icono: Icons.language_outlined, controller: _idiomasController, hintText: "Ej: Español, Inglés"),
      const SizedBox(height: 15),
      _buildTextField(label: "Descripción", icono: Icons.description_outlined, controller: _descripcionController, hintText: "Breve descripción de tu experiencia", maxLines: 3),

      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(Icons.event_available, color: MiTema.azulOscuro, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('¿Recibir citas en línea?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
              const SizedBox(height: 2),
              Text(_habilitarCitasDoctor ? 'Los pacientes podrán agendar' : 'No se recibirán citas', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ])),
            Switch(value: _habilitarCitasDoctor, onChanged: (bool valor) {
              setState(() {
                _habilitarCitasDoctor = valor;
                if (!valor) _duracionCitaSeleccionada = null;
                else if (_duracionCitaSeleccionada == null) _duracionCitaSeleccionada = '30';
              });
            }, activeColor: MiTema.verde, inactiveThumbColor: Colors.grey),
          ],
        ),
      ),

      if (_habilitarCitasDoctor) ...[
        const SizedBox(height: 15),
        _buildDropdownFieldDuracion(),
      ],
      
      if (_habilitarCitasDoctor) ...[
        const SizedBox(height: 24),
        Row(children: [
          const Text('HORARIOS DE ATENCIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Spacer(),
          TextButton.icon(onPressed: _agregarHorario, icon: const Icon(Icons.add_circle_outline, size: 18), label: const Text('Agregar'), style: TextButton.styleFrom(foregroundColor: MiTema.azulOscuro)),
        ]),
        const SizedBox(height: 8),
        
        if (_listaHorarios.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: Row(children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(child: Text('Agrega tus horarios. Puedes tener múltiples turnos.', style: TextStyle(fontSize: 11, color: Colors.grey.shade700))),
          ]))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _listaHorarios.length,
            itemBuilder: (context, index) {
              final horario = _listaHorarios[index];
              return Dismissible(
                key: Key('horario_${horario['id']}'),
                direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: MiTema.rojoerror, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_outline, color: Colors.white, size: 28)),
                confirmDismiss: (direction) async => await _confirmarYEliminar(index).then((_) => false),
                onDismissed: (direction) => _confirmarYEliminar(index),
                child: Card(margin: const EdgeInsets.only(bottom: 8), color: Colors.grey.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(
                  leading: CircleAvatar(backgroundColor: MiTema.azulOscuro, child: Text(_obtenerNombreDia(horario['dia']).substring(0, 3).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  title: Text(_obtenerNombreDia(horario['dia']), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text('${horario['inicio'].substring(0, 5)} - ${horario['fin'].substring(0, 5)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  trailing: IconButton(icon: Icon(Icons.delete_outline, color: Colors.grey.shade400), onPressed: () => _confirmarYEliminar(index), tooltip: 'Eliminar horario'),
                )),
              );
            },
          ),
      ],
    ]);
  }

  Widget _buildDropdownFieldDuracion() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: Text("DURACIÓN PROMEDIO DE CITA".toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1))),
      Container(
        decoration: BoxDecoration(color: MiTema.gris, borderRadius: BorderRadius.circular(50)),
        child: DropdownButtonFormField<String>(
          value: _duracionCitaSeleccionada,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
          decoration: InputDecoration(prefixIcon: Icon(Icons.access_time, color: MiTema.azulOscuro, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), hintText: 'Seleccionar duración', hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          style: TextStyle(fontSize: 14, color: MiTema.negro, fontWeight: FontWeight.w500),
          dropdownColor: MiTema.blanco,
          borderRadius: BorderRadius.circular(20),
          items: _duracionCitasOpciones.map((op) => DropdownMenuItem<String>(value: op['valor'] as String, child: Text(op['etiqueta'] as String))).toList(),
          onChanged: (String? valor) => setState(() => _duracionCitaSeleccionada = valor),
        ),
      ),
    ]);
  }

  Widget _buildDropdownFieldEspecialidades() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: Text("ESPECIALIDAD".toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1))),
      Container(
        decoration: BoxDecoration(color: MiTema.gris, borderRadius: BorderRadius.circular(50)),
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          value: _espIdSeleccionada,
          icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
          decoration: InputDecoration(prefixIcon: Icon(Icons.star_border, color: MiTema.azulOscuro, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), hintText: _especialidadActual.isNotEmpty ? "Actual: $_especialidadActual" : "Selecciona una especialidad", hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          style: TextStyle(fontSize: 14, color: MiTema.negro, fontWeight: FontWeight.w500),
          dropdownColor: MiTema.blanco,
          borderRadius: BorderRadius.circular(20),
          items: _especialidades.isEmpty ? [] : _especialidades.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre))).toList(),
          onChanged: _especialidades.isEmpty ? null : (val) => setState(() => _espIdSeleccionada = val),
          validator: (v) => v == null ? 'Selecciona una especialidad' : null,
        ),
      ),
    ]);
  }

  Widget _buildSectionCard({
    required String title, 
    required IconData icon, 
    required List<Widget> children
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: MiTema.blanco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: MiTema.azulOscuro.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                left: BorderSide(color: MiTema.azulOscuro, width: 4),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: MiTema.azulOscuro, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MiTema.azulOscuro,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icono,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    double opacity = 1.0,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1))),
      TextFormField(
        enabled: enabled,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14, color: MiTema.negro.withOpacity(opacity), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icono, color: MiTema.azulOscuro, size: 20),
          filled: true,
          fillColor: MiTema.gris,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ),
    ]);
  }

  Widget _iconoFallback() => Container(color: Colors.grey.shade300, child: Icon(Icons.account_circle, size: 100, color: Colors.grey.shade600));
}