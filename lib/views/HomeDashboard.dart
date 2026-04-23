import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:magicoon_icons/icon_data/magicoon_filled_icons.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/especialidad.dart';
import 'package:buscadoc_mobile/views/busqueda.dart';
import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:get/get.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/views/doctor/EspecialidadDetails.dart';

class HomeDashboard extends StatefulWidget {
  final String role;
  final String userName;

  const HomeDashboard({super.key, required this.role, required this.userName});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  GoogleMapController? _mapController;
  Map<String, dynamic>? _markerSeleccionado;

  bool _cargando = true;
  Map<String, dynamic>? _dashboard;

  List<Especialidades> _listaEspecialidades = [];
  
  String _selectedRole = 'doctor';
  String? _selectedSpecialty;
  final TextEditingController _searchController = TextEditingController();
  int _limiteEspecialidades = 2;

  @override
  void initState() {
    super.initState();
    _showDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

Future<void> _showDashboardData() async {
  try {
    final token = await Usuario.obtenerToken();
    
    if (token == null) {
      print('❌ No hay token disponible');
      if (mounted) setState(() => _cargando = false);
      return;
    }

    print('🔍 INICIANDO CARGA DE DASHBOARD...');
    print('  Token: ${token.substring(0, 20)}...');

    final dashboardFuture = Usuario.dashboard(token);
    final especialidadesDashboardFuture = Especialidades.getDashboardEspecialidades();
    final especialidadesBuscadorFuture = Especialidades.all();

    final results = await Future.wait([
      dashboardFuture, 
      especialidadesDashboardFuture, 
      especialidadesBuscadorFuture
    ], eagerError: false);

    if (!mounted) return;

    setState(() {
      final dashboardResponse = results[0];
      
      print('📦 RESPONSE DEL DASHBOARD:');
      print('  Tipo: ${dashboardResponse.runtimeType}');
      print('  Contenido: $dashboardResponse');
      
      if (dashboardResponse is Map<String, dynamic>) {
        print('  Success: ${dashboardResponse['success']}');
        print('  Data: ${dashboardResponse['data']}');
        
        if (dashboardResponse['success'] == true) {
          _dashboard = dashboardResponse['data'] as Map<String, dynamic>?;
          
          // 🔍 Verificar campos específicos
          print(' CAMPOS DEL DASHBOARD:');
          print('  Keys: ${_dashboard?.keys.toList()}');
          print('  proxima_cita: ${_dashboard?['proxima_cita']}');
          print('  ultima_review: ${_dashboard?['ultima_review']}');
          print('  ultima_question: ${_dashboard?['ultima_question']}');
        }
      }

      // ... resto del código ...
      _cargando = false;
    });
  } catch (e, stackTrace) {
    print('❌ ERROR CARGANDO DASHBOARD: $e');
    print('Stack trace: $stackTrace');
    if (mounted) setState(() => _cargando = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
          : _buildBodyByRole(),
    );
  }

  Widget _buildBodyByRole() {
    final currentRole = widget.role.toLowerCase();
    return currentRole == 'doctor' ? _buildDoctorDashboard() : _buildPacienteDashboard();
  }

  Widget _buildDoctorDashboard() {
    final proximaCita = _dashboard?['proxima_cita'] as Map<String, dynamic>?;
    final ultimaOpinion = _dashboard?['ultima_review'] as Map<String, dynamic>?;
    final ultimaPregunta = _dashboard?['ultima_question'] as Map<String, dynamic>?;

    String textoCita = "Sin citas próximas";
    if (proximaCita != null) {
      try {
        final paciente = proximaCita['paciente'] as Map<String, dynamic>?;
        final userData = paciente?['user'] as Map<String, dynamic>?;
        final nombrePaciente = userData?['name'] as String? ?? 'Paciente';
        final fechaHora = proximaCita['fecha_hora']?.toString() ?? '';
        String hora = '--:--';
        
        if (fechaHora.contains(' ')) {
          final partes = fechaHora.split(' ');
          if (partes.length > 1) {
            hora = partes[1].length >= 5 ? partes[1].substring(0, 5) : '--:--';
          }
        } else if (fechaHora.contains('T')) {
          final partes = fechaHora.split('T');
          if (partes.length > 1) {
            hora = partes[1].length >= 5 ? partes[1].substring(0, 5) : '--:--';
          }
        }
        
        textoCita = "$nombrePaciente - $hora";
      } catch (_) {
        textoCita = "Cita - Hora no disponible";
      }
    }

    String textoOpinion = "Aún no tienes opiniones";
    String autorOpinion = "Anónimo";
    String? fotoOpinion;
    String? calificacionOpinion;

    if (ultimaOpinion != null) {
      textoOpinion = ultimaOpinion['contenido'] as String? ?? textoOpinion;
      final autor = ultimaOpinion['autor'] as Map<String, dynamic>?;
      autorOpinion = autor?['name'] as String? ?? autorOpinion;
      fotoOpinion = autor?['foto'] as String?;
      calificacionOpinion = ultimaOpinion['calificacion']?.toString();
    }

    String textoPregunta = "Aún no tienes preguntas";
    String autorPregunta = "Anónimo";
    String? fotoPregunta;

    if (ultimaPregunta != null) {
      textoPregunta = ultimaPregunta['contenido'] as String? ?? textoPregunta;
      final autor = ultimaPregunta['autor'] as Map<String, dynamic>?;
      autorPregunta = autor?['name'] as String? ?? autorPregunta;
      fotoPregunta = autor?['foto'] as String?;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Panel Médico", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)),
          Text("Bienvenido, Dr. ${widget.userName}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),

          const Text("Acciones Rápidas", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildQuickAction("Agenda", BootstrapIcons.calendar2_fill, MiTema.azulOscuro)),
              const SizedBox(width: 15),
              Expanded(child: _buildQuickAction("Mensajes", BootstrapIcons.chat_fill, MiTema.azulOscuro)),
            ],
          ),

          const SizedBox(height: 30),
          const Text("Resumen del día", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildDate("Siguiente cita", textoCita, BootstrapIcons.calendar3, MiTema.azulOscuro),
          
          if (ultimaOpinion != null)
            _buildFeedbackCard(
              title: "Última Opinión",
              headerIcon: Icons.star,
              content: textoOpinion,
              authorName: autorOpinion,
              authorPhoto: fotoOpinion,
              rating: calificacionOpinion,
            ),

          if (ultimaPregunta != null)
            _buildFeedbackCard(
              title: "Última pregunta",
              headerIcon: Icons.question_mark_rounded,
              content: textoPregunta,
              authorName: autorPregunta,
              authorPhoto: fotoPregunta,
            ),
        ],
      ),
    );
  }

  Widget _buildPacienteDashboard() {
    final especialidadesDashboard = (_dashboard?['especialidades'] as List<Especialidades>?) ?? [];
    final rutasDashboard = (_dashboard?['rutas'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hola, ${widget.userName}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)),
          const Text("Encuentra lo que buscas, aquí mismo.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),

          _buildMobileSearchCard(_listaEspecialidades),
          const SizedBox(height: 35),
          _buildSeccionEspecialidades(especialidadesDashboard),
          const SizedBox(height: 35),
          _buildMapaUbicaciones(rutasDashboard),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildFeedbackCard({
    required String title,
    required IconData headerIcon,
    required String content,
    required String authorName,
    String? authorPhoto,
    String? rating,
  }) {
    final imagePrefix = '${Globals.webUrl}/storage/';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: MiTema.azulOscuro.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(headerIcon, color: MiTema.azulOscuro, size: 22),
              ),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ]),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
            decoration: const BoxDecoration(color: Color(0xFFFAFAFA), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"$content"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700, fontSize: 14, height: 1.4)),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: (authorPhoto != null && authorPhoto.isNotEmpty)
                            ? NetworkImage('$imagePrefix$authorPhoto')
                            : null,
                        child: (authorPhoto == null || authorPhoto.isEmpty)
                            ? Text(authorName.isNotEmpty ? authorName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                    if (rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20), color: Colors.white),
                        child: Row(children: [
                          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                        ]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDate(String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildMobileSearchCard(List<Especialidades> especialidades) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Nombre del doctor o Farmacia",
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF5F7F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            flex: _selectedRole == 'doctor' ? 1 : 2,
            child: _buildCustomDropdown(
              value: _selectedRole,
              icon: BootstrapIcons.funnel,
              items: const [
                DropdownMenuItem(value: 'doctor', child: Text("Doctores", style: TextStyle(fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'farmacia', child: Text("Farmacias", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedRole = val.toString();
                  if (_selectedRole == 'farmacia') _selectedSpecialty = null;
                });
              },
            ),
          ),
          if (_selectedRole == 'doctor') ...[
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildCustomDropdown(
                value: _selectedSpecialty,
                icon: BootstrapIcons.star,
                hint: "Especialidad...",
                items: especialidades.map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.nombre, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _selectedSpecialty = val.toString()),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              final textoBusqueda = _searchController.text.trim();
              Navigator.push(context, MaterialPageRoute(builder: (context) => BusquedaResultados(query: textoBusqueda, type: _selectedRole, especialidadId: _selectedSpecialty)));
            },
            icon: const Icon(BootstrapIcons.search, color: Colors.white, size: 18),
            label: const Text("Buscar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), elevation: 0),
          ),
        )
      ]),
    );
  }

  Widget _buildCustomDropdown({
    required dynamic value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(dynamic) onChanged,
    String hint = "Seleccionar",
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7F9), borderRadius: BorderRadius.circular(50)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          hint: Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(hint, style: const TextStyle(color: Colors.black54), overflow: TextOverflow.ellipsis))]),
          items: items.map((item) => DropdownMenuItem<String>(value: item.value, child: Row(children: [Icon(icon, size: 16, color: MiTema.azulOscuro), const SizedBox(width: 8), Expanded(child: item.child)]))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSeccionEspecialidades(List<dynamic> especialidades) {
    if (especialidades.isEmpty) return const SizedBox.shrink();

    bool mostrarBotonVerMas = _limiteEspecialidades < especialidades.length;
    List<dynamic> especialidadesVisibles = especialidades.take(_limiteEspecialidades).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Nuestras especialidades",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 15),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: especialidades.map((esp) {
              final count = esp.doctores?.length ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 10, bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      // 👇 NAVEGACIÓN A LA NUEVA VISTA
                      Get.to(() => EspecialidadDetalleView(especialidad: esp));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(MagicoonFilled.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            esp.nombre,
                            style: TextStyle(
                              color: MiTema.azulOscuro,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: MiTema.azulOscuro.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color: MiTema.azulOscuro,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 25),

        ...especialidadesVisibles.map((esp) {
          final doctoresRaw = esp.doctores ?? [];
          if (doctoresRaw.isEmpty) return const SizedBox.shrink();
          
          // 👇 1. MAPEAR Y ORDENAR A LOS DOCTORES POR CALIFICACIÓN
          List<Doctores> doctoresOrdenados = doctoresRaw.map<Doctores?>((d) {
            try { return Doctores.fromJson(d); } catch (_) { return null; }
          }).whereType<Doctores>().toList();

          doctoresOrdenados.sort((a, b) => (b.promedio ?? 0.0).compareTo(a.promedio ?? 0.0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esp.nombre,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
              ),
              const SizedBox(height: 15),
              
              SizedBox(
                height: 245, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: doctoresOrdenados.length, // Usamos la lista ordenada
                  itemBuilder: (context, index) {
                    final docMapeado = doctoresOrdenados[index]; // Ya es un objeto Doctores
                    
                    final docName = docMapeado.nombre;
                    final imgUrl = docMapeado.image; 
                    final bool tieneFoto = imgUrl.isNotEmpty && !imgUrl.contains('placeholder');
                    
                    final bool esDescanso = docMapeado.horarioentrada == 'Descanso' || docMapeado.horarioentrada.isEmpty;
                    bool estaDisponibleAhora = false;

                    if (!esDescanso) {
                      try {
                        final partesEntrada = docMapeado.horarioentrada.split(':');
                        final partesSalida = docMapeado.horariosalida.split(':');
                        
                        if (partesEntrada.length >= 2 && partesSalida.length >= 2) {
                          int hE = int.parse(partesEntrada[0]);
                          int mE = int.parse(partesEntrada[1]);
                          int hS = int.parse(partesSalida[0]);
                          int mS = int.parse(partesSalida[1]);
                          
                          TimeOfDay ahora = TimeOfDay.now();
                          double nowVal = ahora.hour + (ahora.minute / 60.0);
                          if (nowVal >= (hE + (mE / 60.0)) && nowVal <= (hS + (mS / 60.0))) {
                            estaDisponibleAhora = true;
                          }
                        }
                      } catch (_) {}
                    }

                    Color bgColor;
                    Color textColor;
                    String textoPildora;
                    IconData iconoPildora = MagicoonFilled.clock;

                    if (esDescanso) {
                      bgColor = Colors.red.shade50;
                      textColor = Colors.red.shade700;
                      textoPildora = 'Hoy no atiende';
                      iconoPildora = MagicoonFilled.moon;
                    } else if (!estaDisponibleAhora) {
                      bgColor = Colors.orange.shade50;
                      textColor = Colors.orange.shade800;
                      textoPildora = 'No disponible ahora';
                    } else {
                      bgColor = Colors.green.shade50;
                      textColor = Colors.green.shade700;
                      textoPildora = '${docMapeado.horarioentrada} - ${docMapeado.horariosalida}';
                    }

                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 15, bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                            backgroundImage: tieneFoto ? NetworkImage(imgUrl) : null,
                            child: !tieneFoto
                                ? Text(docName.isNotEmpty ? docName[0].toUpperCase() : 'D', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MiTema.azulOscuro))
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            docName.startsWith("Dr") ? docName : "Dr. $docName",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // 👇 OPCIONAL: Puedes mostrar las estrellas aquí también para confirmar que sirve
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(MagicoonFilled.star, color: Colors.amber, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                (docMapeado.promedio ?? 0.0).toStringAsFixed(1),
                                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(iconoPildora, size: 10, color: textColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(textoPildora, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Get.to(() => DoctorDetailsView(doctor: docMapeado)),
                              style: OutlinedButton.styleFrom(side: BorderSide(color: MiTema.azulOscuro), foregroundColor: MiTema.azulOscuro, padding: const EdgeInsets.symmetric(vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                              child: const Text("Ver Perfil", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),

        if (mostrarBotonVerMas)
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _limiteEspecialidades += 2; 
                });
              },
              icon: Icon(MagicoonRegular.angleDown, color: MiTema.azulOscuro),
              label: Text(
                "Mostrar más especialidades",
                style: TextStyle(
                  color: MiTema.azulOscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapaUbicaciones(List<dynamic> rutas) {
    if (rutas.isEmpty) return const SizedBox.shrink();
    
    // 👇 1. CLONAMOS Y ORDENAMOS LA LISTA (Mayor calificación primero)
    List<dynamic> rutasOrdenadas = List.from(rutas);
    rutasOrdenadas.sort((a, b) {
      if (a is! Map<String, dynamic> || b is! Map<String, dynamic>) return 0;
      
      double promA = double.tryParse(a['promedio']?.toString() ?? '0') ?? 0.0;
      double promB = double.tryParse(b['promedio']?.toString() ?? '0') ?? 0.0;
      
      return promB.compareTo(promA); // Orden descendente
    });

    final markers = <Marker>{};
    // Pasamos a iterar sobre la lista YA ORDENADA
    for (final ruta in rutasOrdenadas) {
      if (ruta is! Map<String, dynamic>) continue;
      
      final lat = double.tryParse(ruta['latitud']?.toString() ?? '0') ?? 0;
      final lng = double.tryParse(ruta['longitud']?.toString() ?? '0') ?? 0;
      if (lat == 0 && lng == 0) continue;
      
      markers.add(Marker(
        markerId: MarkerId(ruta['id']?.toString() ?? 'unknown'),
        position: LatLng(lat, lng),
        onTap: () {
          setState(() {
            _markerSeleccionado = ruta;
          });
        },
      ));
    }

    LatLng centroInicial = const LatLng(16.9084, -92.0977);
    // Centramos el mapa en el doctor MEJOR CALIFICADO
    if (rutasOrdenadas.isNotEmpty && rutasOrdenadas[0] is Map<String, dynamic>) {
      final first = rutasOrdenadas[0] as Map<String, dynamic>;
      final lat = double.tryParse(first['latitud']?.toString() ?? '') ?? 16.9084;
      final lng = double.tryParse(first['longitud']?.toString() ?? '') ?? -92.0977;
      centroInicial = LatLng(lat, lng);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Clínicas y Farmacias en tu zona", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Descubre a los profesionales de la salud cerca de ti.", style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: centroInicial, zoom: 14),
                  markers: markers,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (_) {
                    if (_markerSeleccionado != null) {
                      setState(() => _markerSeleccionado = null);
                    }
                  },
                ),
                
                if (_markerSeleccionado != null)
                  Positioned(
                    top: 15,
                    left: 15,
                    right: 15,
                    child: _buildMarcadorFlotante(_markerSeleccionado!),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 15),

        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: rutasOrdenadas.length,
            itemBuilder: (context, index) {
              final ruta = rutasOrdenadas[index];
              if (ruta is! Map<String, dynamic>) return const SizedBox.shrink();
              
              final nombre = ruta['name']?.toString() ?? 'Desconocido';
              final role = ruta['role']?.toString() ?? '';
              final foto = ruta['foto'] as String?;
              final imgUrl = foto != null ? '${Globals.webUrl}/storage/$foto' : '';
              
              final lat = double.tryParse(ruta['latitud']?.toString() ?? '0') ?? 0;
              final lng = double.tryParse(ruta['longitud']?.toString() ?? '0') ?? 0;
              
              final promedio = double.tryParse(ruta['promedio']?.toString() ?? '0') ?? 0.0;

              return GestureDetector(
                onTap: () {
                  if (_mapController != null && lat != 0 && lng != 0) {
                    _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
                    setState(() {
                      _markerSeleccionado = ruta;
                    });
                  }
                },
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 15, bottom: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundImage: foto != null ? NetworkImage(imgUrl) : null,
                      backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                      child: foto == null ? Icon(role == 'doctor' ? Icons.person : Icons.local_pharmacy, color: MiTema.azulOscuro) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          
                          Row(
                            children: [
                              Text(role.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                              if (role == 'doctor' && promedio > 0) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(promedio.toStringAsFixed(1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarcadorFlotante(Map<String, dynamic> data) {
    final bool isDoctor = data['role'] == 'doctor';
    final String nombre = data['name'] ?? 'Desconocido';
    final String? foto = data['foto'];
    final String imgUrl = foto != null ? '${Globals.webUrl}/storage/$foto' : '';

    if (!isDoctor) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: Icon(Icons.local_pharmacy, color: Colors.green.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold, color: MiTema.azulOscuro, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    String especialidad = 'Especialista';
    if (data['especialidades'] != null && (data['especialidades'] as List).isNotEmpty) {
      especialidad = data['especialidades'][0]['nombre'] ?? 'Especialista';
    } else if (data['especialidad'] != null) {
      especialidad = data['especialidad'].toString();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: foto != null ? NetworkImage(imgUrl) : null,
            backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
            child: foto == null ? Icon(Icons.person, color: MiTema.azulOscuro) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre.startsWith("Dr") ? nombre : "Dr. $nombre", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: MiTema.azulOscuro, fontSize: 14), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                Text(
                  especialidad, 
                  style: const TextStyle(color: Colors.grey, fontSize: 11), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}