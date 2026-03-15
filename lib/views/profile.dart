import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:buscadoc_mobile/model/especialidad.dart';
import 'package:buscadoc_mobile/utils/global.dart';

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

  late TextEditingController _especialidadController;
  late TextEditingController _descripcionController;
  late TextEditingController _cedulaController;
  late TextEditingController _costosController;
  late TextEditingController _horarioEntradaController;
  late TextEditingController _horarioSalidaController;

  late List<Especialidades> _especialidades = [];
  int? _espIdSeleccionada;
  String _especialidadActual = "";

  bool _guardando = false;
  bool _cargandoPerfil = true;
  // bool _cargandoEsp = true;
  Map<String, dynamic>? _datosPerfil;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreActual);
    _correoController = TextEditingController(text: widget.correoActual);
    _telefonoController = TextEditingController(text: "");

    _tipoSangreController = TextEditingController(text: "");
    _alergiasController = TextEditingController(text: "");
    _cirugiasController = TextEditingController(text: "");
    _padecimientosController = TextEditingController(text: "");
    _habitosController = TextEditingController(text: "");
    _contactoEmergenciaController = TextEditingController(text: "");

    _especialidadController = TextEditingController(text: "");
    _descripcionController = TextEditingController(text: "");
    _cedulaController = TextEditingController(text: "");
    _costosController = TextEditingController(text: "");
    _horarioEntradaController = TextEditingController(text: "");
    _horarioSalidaController = TextEditingController(text: "");

    _showData();
  }

  Future<void> _showData() async {
    List<Especialidades> especialidadesApi = await Especialidades.all();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? idString = prefs.getString('id');

    if (token != null && idString != null) {
      int myId = int.parse(idString);
      var response = await Usuario.show(token, myId);

      if (response['success']) {
        setState(() {
          _datosPerfil = response['data'];
          _especialidades = especialidadesApi;

          _nombreController.text = _datosPerfil?['name'] ?? widget.nombreActual;
          _correoController.text = _datosPerfil?['email'] ?? widget.correoActual;

          if (_datosPerfil?['role'] == 'paciente') {
            _tipoSangreController.text = _datosPerfil?['tipo_sangre'] ?? '';
            _alergiasController.text = _datosPerfil?['alergias'] ?? '';
            _cirugiasController.text = _datosPerfil?['cirugias'] ?? '';
            _padecimientosController.text = _datosPerfil?['padecimientos'] ?? '';
            _habitosController.text = _datosPerfil?['habitos'] ?? '';
            _contactoEmergenciaController.text = _datosPerfil?['contacto_emergencia'] ?? '';
          } else if (_datosPerfil?['role'] == 'doctor') {
            _especialidadActual = _datosPerfil?['especialidad'] ?? ''; 
            
            // 🔥 1. BÚSQUEDA A PRUEBA DE BALAS 🔥
            if (_especialidadActual.isNotEmpty && _especialidades.isNotEmpty) {
              // Si Laravel mandó varias separadas por coma, tomamos solo la primera
              String nombreABuscar = _especialidadActual.split(',').first.trim().toLowerCase();

              try {
                // Buscamos ignorando mayúsculas y espacios
                final espEncontrada = _especialidades.firstWhere(
                  (esp) => esp.nombre.trim().toLowerCase() == nombreABuscar
                );
                _espIdSeleccionada = espEncontrada.id;
              } catch (e) {
                // Si de plano no existe, lo dejamos nulo
                _espIdSeleccionada = null;
              }
            }

            // 🔥 2. EL SALVAVIDAS DEL DROPDOWN 🔥
            // Verificamos que el ID seleccionado REALMENTE exista en la lista actual.
            // Si no existe, lo volvemos nulo para evitar que el menú se trabe.
            if (_espIdSeleccionada != null) {
              bool idExiste = _especialidades.any((esp) => esp.id == _espIdSeleccionada);
              if (!idExiste) {
                _espIdSeleccionada = null;
              }
            }

            _descripcionController.text = _datosPerfil?['descripcion'] ?? '';
            _cedulaController.text = _datosPerfil?['cedula'] ?? '';
            _costosController.text = _datosPerfil?['costos']?.toString() ?? '';
            _horarioEntradaController.text = _datosPerfil?['horarioentrada'] ?? '';
            _horarioSalidaController.text = _datosPerfil?['horariosalida'] ?? '';
          }

          _cargandoPerfil = false;
        });
      } else {
        setState(() => _cargandoPerfil = false);
      }
    } else {
      setState(() => _cargandoPerfil = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _tipoSangreController.dispose();
    _alergiasController.dispose();
    _cirugiasController.dispose();
    _padecimientosController.dispose();
    _habitosController.dispose();
    _contactoEmergenciaController.dispose();
    _especialidadController.dispose();
    _descripcionController.dispose();
    _cedulaController.dispose();
    _costosController.dispose();
    _horarioEntradaController.dispose();
    _horarioSalidaController.dispose();
    super.dispose();
  }



  Future<void> _selectTime(TextEditingController controller) async {
    Time initialTime = Time(hour: 8, minute: 0); 
    
    if (controller.text.isNotEmpty) {
      try {
        final List<String> parts = controller.text.split(':');
        initialTime = Time(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        // Ni pedo
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

  Future<void> _save() async {
    if (_datosPerfil?['role'] == 'doctor' && _espIdSeleccionada == null) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: const Text("Por favor selecciona tu especialidad"),
                    backgroundColor: MiTema.rojoerror,
                    behavior: SnackBarBehavior.floating,
                ),
            );
        }
        return;
    }

    setState(() => _guardando = true);

    // 2. RECUPERAMOS EL TOKEN Y EL ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? idString = prefs.getString('id');

    if (token == null || idString == null) {
      setState(() => _guardando = false);
      return;
    }
    
    int myId = int.parse(idString);

    Map<String, dynamic> datosAEnviar = {
      "name": _nombreController.text.trim(),
      "email": _correoController.text.trim(),
    };

    if (_datosPerfil?['role'] == 'paciente') {
      datosAEnviar.addAll({
        "tipo_sangre": _tipoSangreController.text.trim(),
        "alergias": _alergiasController.text.trim(),
        "cirugias": _cirugiasController.text.trim(),
        "padecimientos": _padecimientosController.text.trim(),
        "habitos": _habitosController.text.trim(),
        "contacto_emergencia": _contactoEmergenciaController.text.trim(),
      });
    } else if (_datosPerfil?['role'] == 'doctor') {
      datosAEnviar.addAll({
        "especialidad_id": _espIdSeleccionada,
        "descripcion": _descripcionController.text.trim(),
        "cedula": _cedulaController.text.trim(),
        "costos": _costosController.text.trim(),
        "horarioentrada": _horarioEntradaController.text.trim(),
        "horariosalida": _horarioSalidaController.text.trim(),
      });
    }

    var response = await Usuario.update(token, myId, datosAEnviar);
    
    setState(() => _guardando = false);

    if (mounted) {
      if (response['success']) {
        
        await prefs.setString('userName', _nombreController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: MiTema.verde,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: MiTema.rojoerror,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = "$Globals.urlWeb/storage/";
    String urlFinal = widget.fotoActual.startsWith('http')
        ? widget.fotoActual
        : baseUrl + widget.fotoActual;

    return Scaffold(
      backgroundColor: MiTema.gris,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Editar Perfil",
          style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: MiTema.azulOscuro),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cargandoPerfil
        ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                        border: Border.all(
                          color: MiTema.azulOscuro,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: widget.fotoActual.isNotEmpty
                              ? NetworkImage(urlFinal)
                              : const AssetImage(
                                  'assets/default_avatar.png',
                                ) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MiTema.azulOscuro,
                            shape: BoxShape.circle,
                            border: Border.all(color: MiTema.blanco, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionCard(
                title: "Información General",
                icon: Icons.person,
                children: [
                  _buildTextField(
                    label: "Nombre completo",
                    icono: Icons.person_outline,
                    controller: _nombreController,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: "Correo electrónico",
                    icono: Icons.email_outlined,
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  if (_datosPerfil?['role'] == 'paciente') ...[
                    _buildTextField(
                      label: "Teléfono",
                      icono: Icons.phone_outlined,
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ],
              ),
              if (_datosPerfil?['role'] == 'paciente') ...[
                _buildSectionCard(
                  title: "Perfil Médico",
                  icon: Icons.monitor_heart_outlined,
                  children: [
                    _buildTextField(
                      label: "Tipo de Sangre",
                      icono: Icons.bloodtype_outlined,
                      controller: _tipoSangreController,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Alergias",
                      icono: Icons.warning_amber_rounded,
                      controller: _alergiasController,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Cirugías",
                      icono: Icons.content_cut,
                      controller: _cirugiasController,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Padecimientos",
                      icono: Icons.sick_outlined,
                      controller: _padecimientosController,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Hábitos",
                      icono: Icons.accessibility_new_rounded,
                      controller: _habitosController,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Contacto de Emergencia",
                      icono: Icons.contact_emergency_outlined,
                      controller: _contactoEmergenciaController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

              ] else if (_datosPerfil?['role'] == 'doctor') ...[
                _buildSectionCard(
                  title: "Perfil Profesional",
                  icon: Icons.medical_information_outlined,
                  children: [
                    _buildDropdownFieldEspecialidades(),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Cédula Profesional",
                      icono: Icons.verified_outlined,
                      controller: _cedulaController,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Costo Consulta",
                      icono: Icons.attach_money,
                      controller: _costosController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Descripción",
                      icono: Icons.description_outlined,
                      controller: _descripcionController,
                    ),
                    const SizedBox(height: 15),
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
                                onTap: () => _selectTime(_horarioEntradaController),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  height: 100, 
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: MiTema.azulOscuro, 
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _horarioEntradaController.text.isNotEmpty
                                          ? _horarioEntradaController.text.substring(0, 5) 
                                          : "08:00",
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
                                onTap: () => _selectTime(_horarioSalidaController),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  height: 100, 
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: MiTema.azulOscuro,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _horarioSalidaController.text.isNotEmpty
                                          ? _horarioSalidaController.text.substring(0, 5) 
                                          : "18:00",
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
                  ],
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MiTema.azulOscuro,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _guardando ? null : _save,
                  child: _guardando
                      ? CircularProgressIndicator(color: MiTema.blanco)
                      : Text(
                          "Guardar Cambios",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MiTema.blanco,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildDropdownFieldEspecialidades() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 8),
          child: Text(
            "ESPECIALIDAD".toUpperCase(),
            style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: MiTema.gris,
            borderRadius: BorderRadius.circular(50),
          ),
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: _espIdSeleccionada, 
            
            icon: Icon(Icons.arrow_drop_down_circle_outlined, color: MiTema.azulOscuro),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.star_border, color: MiTema.azulOscuro, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              hintText: _especialidadActual.isNotEmpty 
                  ? "Actual: $_especialidadActual" 
                  : "Selecciona una especialidad",
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            
            style: TextStyle(fontSize: 14, color: MiTema.negro, fontWeight: FontWeight.w500),
            dropdownColor: MiTema.blanco, 
            borderRadius: BorderRadius.circular(20),
            
            items: _especialidades.isEmpty 
                ? []
                : _especialidades.map((Especialidades especialidad) {
                    return DropdownMenuItem<int>(
                      value: especialidad.id, 
                      child: Text(especialidad.nombre), 
                    );
                  }).toList(),
            
            onChanged: _especialidades.isEmpty 
                ? null
                : (int? nuevoId) {
                    setState(() {
                      _espIdSeleccionada = nuevoId;
                      print("Especialidad seleccionada ID: $_espIdSeleccionada");
                    });
                  },
            
            validator: (value) {
                if (value == null) {
                    return 'Por favor selecciona una especialidad';
                }
                return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: MiTema.blanco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
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
              border: Border(left: BorderSide(color: MiTema.azulOscuro, width: 4)), 
            ),
            child: Row(
              children: [
                Icon(icon, color: MiTema.azulOscuro, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: MiTema.negro, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icono, color: MiTema.azulOscuro, size: 20),
            filled: true,
            fillColor: MiTema.gris,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}