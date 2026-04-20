import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:buscadoc_mobile/model/especialidad.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';
import 'dart:convert' as convert;

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
  late TextEditingController _telefonoController;
  late TextEditingController _tipoSangreController;
  late TextEditingController _alergiasController;
  late TextEditingController _cirugiasController;
  late TextEditingController _padecimientosController;
  late TextEditingController _habitosController;
  late TextEditingController _contactoEmergenciaController;
  late TextEditingController _descripcionController;
  late TextEditingController _cedulaController;
  late TextEditingController _costosController;
  late TextEditingController _horarioEntradaController;
  late TextEditingController _horarioSalidaController;

  // ─────────────────────────────────────────────────────
  // ESTADO
  // ─────────────────────────────────────────────────────
  late List<Especialidades> _especialidades = [];
  int? _espIdSeleccionada;
  String _especialidadActual = "";
  String _roleCache = ''; // ✅ Cache del role para build()

  bool _guardando = false;
  bool _cargandoPerfil = true;
  Map<String, dynamic>? _datosPerfil;

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    _showData();
  }

  void _inicializarControllers() {
    _nombreController = TextEditingController(text: widget.nombreActual);
    _correoController = TextEditingController(text: widget.correoActual);
    _telefonoController = TextEditingController();
    _tipoSangreController = TextEditingController();
    _alergiasController = TextEditingController();
    _cirugiasController = TextEditingController();
    _padecimientosController = TextEditingController();
    _habitosController = TextEditingController();
    _contactoEmergenciaController = TextEditingController();
    _descripcionController = TextEditingController();
    _cedulaController = TextEditingController();
    _costosController = TextEditingController();
    _horarioEntradaController = TextEditingController();
    _horarioSalidaController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose(); _correoController.dispose(); _telefonoController.dispose();
    _tipoSangreController.dispose(); _alergiasController.dispose(); _cirugiasController.dispose();
    _padecimientosController.dispose(); _habitosController.dispose(); _contactoEmergenciaController.dispose();
    _descripcionController.dispose(); _cedulaController.dispose(); _costosController.dispose();
    _horarioEntradaController.dispose(); _horarioSalidaController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────
  // CARGAR DATOS DEL PERFIL
  // ─────────────────────────────────────────────────────
  Future<void> _showData() async {
    try {
      final especialidadesApi = await Especialidades.all();
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
          _especialidades = especialidadesApi;
          _roleCache = _datosPerfil?['role']?.toString() ?? '';

          _nombreController.text = _datosPerfil?['name'] ?? widget.nombreActual;
          _correoController.text = _datosPerfil?['email'] ?? widget.correoActual;

          if (_roleCache == 'paciente') {
            _tipoSangreController.text = _datosPerfil?['tipo_sangre'] ?? '';
            _alergiasController.text = _datosPerfil?['alergias'] ?? '';
            _cirugiasController.text = _datosPerfil?['cirugias'] ?? '';
            _padecimientosController.text = _datosPerfil?['padecimientos'] ?? '';
            _habitosController.text = _datosPerfil?['habitos'] ?? '';
            _contactoEmergenciaController.text = _datosPerfil?['contacto_emergencia'] ?? '';
          } else if (_roleCache == 'doctor') {
            _especialidadActual = _datosPerfil?['especialidad'] ?? '';
            
            if (_especialidadActual.isNotEmpty && _especialidades.isNotEmpty) {
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

            _descripcionController.text = _datosPerfil?['descripcion'] ?? '';
            _cedulaController.text = _datosPerfil?['cedula'] ?? '';
            
            // ✅ Leer costo (limpiar símbolos $ y ,)
            final costoRaw = _datosPerfil?['costo'] ?? _datosPerfil?['costos'] ?? 0;
            _costosController.text = costoRaw.toString().replaceAll(RegExp(r'[^\d.]'), '');
            
            // ✅ Leer horarios con fallback para nombres alternativos
            _horarioEntradaController.text = _formatoHoraParaMostrar(
              _datosPerfil?['horario_entrada'] ?? _datosPerfil?['horarioentrada']
            );
            _horarioSalidaController.text = _formatoHoraParaMostrar(
              _datosPerfil?['horario_salida'] ?? _datosPerfil?['horariosalida']
            );
          }
          _cargandoPerfil = false;
        });
      } else {
        UIUtils.showRoundedSnackBar(context, response['message'], MiTema.rojoerror, MiTema.blanco);
        setState(() => _cargandoPerfil = false);
      }
    } catch (e) {
      print('❌ Error en _showData: $e');
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, 'Error al cargar perfil', MiTema.rojoerror, MiTema.blanco);
      }
      setState(() => _cargandoPerfil = false);
    }
  }

  // ✅ Helper: Formatea hora para mostrar en UI (HH:00)
  String _formatoHoraParaMostrar(dynamic horaRaw) {
    if (horaRaw == null) return '08:00';
    if (horaRaw is String && horaRaw.isNotEmpty) {
      final partes = horaRaw.split(':');
      if (partes.isNotEmpty) {
        final hora = int.tryParse(partes[0]);
        if (hora != null) return '${hora.toString().padLeft(2, '0')}:00';
      }
      return horaRaw;
    }
    if (horaRaw is int) return '${horaRaw.toString().padLeft(2, '0')}:00';
    return '08:00';
  }

  // ─────────────────────────────────────────────────────
  // SELECTOR DE HORA
  // ─────────────────────────────────────────────────────
  Future<void> _selectTime(TextEditingController controller) async {
    Time initialTime =  Time(hour: 8, minute: 0);
    
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split(':');
        initialTime = Time(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {}
    }

    if (!mounted) return;
    
    Navigator.of(context).push(
      showPicker(
        context: context,
        value: initialTime,
        onChange: (newTime) {
          if (!mounted) return;
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
        cancelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        borderRadius: 20,
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // GUARDAR CAMBIOS
  // ─────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_roleCache == 'doctor' && _espIdSeleccionada == null) {
      if (mounted) {
        UIUtils.showRoundedSnackBar(context, "Selecciona tu especialidad", MiTema.rojoerror, MiTema.blanco);
      }
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

      // ✅ Payload base (común para ambos roles)
      final datosAEnviar = <String, dynamic>{
        "name": _nombreController.text.trim(),
        "email": _correoController.text.trim(),
      };

      if (_roleCache == 'paciente') {
        datosAEnviar.addAll({
          "tipo_sangre": _tipoSangreController.text.trim(),
          "alergias": _alergiasController.text.trim(),
          "cirugias": _cirugiasController.text.trim(),
          "padecimientos": _padecimientosController.text.trim(),
          "habitos": _habitosController.text.trim(),
          "contacto_emergencia": _contactoEmergenciaController.text.trim(),
        });
      } else if (_roleCache == 'doctor') {
        // ✅ Campos EXACTOS como espera Laravel UserController@update
        datosAEnviar.addAll({
          "costo": _costosController.text.trim().isEmpty 
              ? 0 
              : num.tryParse(_costosController.text.trim()),
          
          // ✅ Nombres correctos: horario_entrada / horario_salida
          "horario_entrada": _horarioEntradaController.text.isNotEmpty 
              ? _horarioEntradaController.text 
              : "08:00:00",
          "horario_salida": _horarioSalidaController.text.isNotEmpty 
              ? _horarioSalidaController.text 
              : "18:00:00",
          
          "cedula": _cedulaController.text.trim(),
          "descripcion": _descripcionController.text.trim(),
          
          // ✅ especialidad_id como int (no array)
          "especialidad_id": _espIdSeleccionada,
        });
      }

      // ✅ Usar Usuario.update() para AMBOS roles
      final response = await Usuario.update(token, myId, datosAEnviar);
      
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

  // ─────────────────────────────────────────────────────
  // ELIMINAR CUENTA
  // ─────────────────────────────────────────────────────
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
    // ✅ URL de imagen con fallback
    final urlFinal = widget.fotoActual.isNotEmpty
        ? (widget.fotoActual.startsWith('http') 
            ? widget.fotoActual 
            : '${Globals.webUrl}/storage/${widget.fotoActual}')
        : '';

    return Scaffold(
      backgroundColor: MiTema.gris,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Editar Perfil", style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: MiTema.azulOscuro),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cargandoPerfil
        ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(children: [
              // 👤 FOTO DE PERFIL
              Center(
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: urlFinal.isNotEmpty
                        ? Image.network(
                            urlFinal,
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                            errorBuilder: (_, __, ___) => _iconoFallback(),
                          )
                        : _iconoFallback(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // 📋 INFORMACIÓN GENERAL
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

              // 🏥 SECCIÓN SEGÚN ROL
              _buildRoleSection(),

              const SizedBox(height: 40),
              
              // 💾 BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MiTema.azulOscuro,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 5,
                  ),
                  onPressed: _guardando ? null : _save,
                  child: _guardando
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: MiTema.blanco, strokeWidth: 2))
                      : const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              
              // 🗑️ BOTÓN ELIMINAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: MiTema.rojoerror, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
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


  // ✅ Sección condicional según rol
  Widget _buildRoleSection() {
    if (_roleCache == 'paciente') {
      return _buildSectionCard(title: "Perfil Médico", icon: Icons.monitor_heart_outlined, children: [
        _buildTextField(label: "Tipo de Sangre", icono: Icons.bloodtype_outlined, controller: _tipoSangreController),
        const SizedBox(height: 15),
        _buildTextField(label: "Alergias", icono: Icons.warning_amber_rounded, controller: _alergiasController),
        const SizedBox(height: 15),
        _buildTextField(label: "Cirugías", icono: Icons.content_cut, controller: _cirugiasController),
        const SizedBox(height: 15),
        _buildTextField(label: "Padecimientos", icono: Icons.sick_outlined, controller: _padecimientosController),
        const SizedBox(height: 15),
        _buildTextField(label: "Hábitos", icono: Icons.accessibility_new_rounded, controller: _habitosController),
        const SizedBox(height: 15),
        _buildTextField(label: "Contacto de Emergencia", icono: Icons.contact_emergency_outlined, controller: _contactoEmergenciaController, keyboardType: TextInputType.phone),
      ]);
    } else if (_roleCache == 'doctor') {
      return _buildSectionCard(title: "Perfil Profesional", icon: Icons.medical_information_outlined, children: [
        _buildDropdownFieldEspecialidades(),
        const SizedBox(height: 15),
        _buildTextField(label: "Cédula Profesional", icono: Icons.verified_outlined, controller: _cedulaController),
        const SizedBox(height: 15),
        _buildTextField(label: "Costo Consulta", icono: Icons.attach_money, controller: _costosController, keyboardType: TextInputType.number),
        const SizedBox(height: 15),
        _buildTextField(label: "Descripción", icono: Icons.description_outlined, controller: _descripcionController),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: _buildTimeButton("ENTRADA", _horarioEntradaController, () => _selectTime(_horarioEntradaController))),
          const SizedBox(width: 15),
          Expanded(child: _buildTimeButton("SALIDA", _horarioSalidaController, () => _selectTime(_horarioSalidaController))),
        ]),
      ]);
    } else {
      // Fallback si el role no es reconocido
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 40),
          const SizedBox(height: 10),
          Text('Rol no reconocido: "${_roleCache}"', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
          const SizedBox(height: 5),
          Text('Contacta a soporte si este mensaje persiste.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
        ]),
      );
    }
  }

  // ✅ Botón circular para seleccionar hora
  Widget _buildTimeButton(String label, TextEditingController ctrl, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 8),
        child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: MiTema.azulOscuro, shape: BoxShape.circle),
          child: Center(
            child: Text(
              ctrl.text.isNotEmpty ? ctrl.text.substring(0, 5) : "08:00",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MiTema.blanco),
            ),
          ),
        ),
      ),
    ]);
  }

  // ✅ Fallback para imagen de perfil
  Widget _iconoFallback() => Container(
    color: Colors.grey.shade300,
    child: Icon(Icons.account_circle, size: 100, color: Colors.grey.shade600),
  );

  // ✅ Dropdown de especialidades
  Widget _buildDropdownFieldEspecialidades() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 8),
        child: Text("ESPECIALIDAD".toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      Container(
        decoration: BoxDecoration(color: MiTema.gris, borderRadius: BorderRadius.circular(50)),
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          value: _espIdSeleccionada,
          icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.star_border, color: MiTema.azulOscuro, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            hintText: _especialidadActual.isNotEmpty ? "Actual: $_especialidadActual" : "Selecciona una especialidad",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          style: TextStyle(fontSize: 14, color: MiTema.negro, fontWeight: FontWeight.w500),
          dropdownColor: MiTema.blanco,
          borderRadius: BorderRadius.circular(20),
          items: _especialidades.isEmpty 
              ? [] 
              : _especialidades.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre))).toList(),
          onChanged: _especialidades.isEmpty ? null : (val) => setState(() => _espIdSeleccionada = val),
          validator: (v) => v == null ? 'Selecciona una especialidad' : null,
        ),
      ),
    ]);
  }

  // ✅ Card reutilizable para secciones
  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: MiTema.blanco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: MiTema.azulOscuro.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(left: BorderSide(color: MiTema.azulOscuro, width: 4)),
          ),
          child: Row(children: [
            Icon(icon, color: MiTema.azulOscuro, size: 22),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)),
          ]),
        ),
        Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: children)),
      ]),
    );
  }

  // ✅ TextField reutilizable
  Widget _buildTextField({
    required String label,
    required IconData icono,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    double opacity = 1.0,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 8),
        child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      TextFormField(
        enabled: enabled,
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14, color: MiTema.negro.withOpacity(opacity), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icono, color: MiTema.azulOscuro, size: 20),
          filled: true,
          fillColor: MiTema.gris,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ]);
  }
}