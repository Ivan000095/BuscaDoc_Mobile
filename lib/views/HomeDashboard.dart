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

class HomeDashboard extends StatefulWidget {
  final String role;
  final String userName;

  const HomeDashboard({super.key, required this.role, required this.userName});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late GoogleMapController mapController;
  // final LatLng _centroOcosingo = const LatLng(16.9084, -92.0977);

  bool _cargando = true;
  Map<String, dynamic>? _dashboard;

  List<Especialidades> _listaEspecialidades = [];
  
  String _selectedRole = 'doctor';
  String? _selectedSpecialty;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showDashboardData();
  }

  Future<void> _showDashboardData() async {
    String? token = await Usuario.obtenerToken();
    

    if (token == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    var responseDashboard = await Usuario.dashboard(token);
    var especialidadesConDoctores = await Especialidades.getDashboardEspecialidades();
    
    Future<void> cargarEspecialidadesParaBuscador() async {
      var response = await Especialidades.all();
      if(mounted) setState(() { _listaEspecialidades = response; });
    }
    
    if (mounted) {
      setState(() {
        if (responseDashboard['success']) {
          _dashboard = responseDashboard['data'];
          
          _dashboard?['especialidades'] = especialidadesConDoctores; 
        } 
        cargarEspecialidadesParaBuscador(); 

        _cargando = false;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
          : _buildBodyByRole(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showChatbot(context),
      //   backgroundColor: MiTema.azulOscuro,
      //   child: const Icon(Icons.robot, color: Colors.white),
      // ),
    );
  }

  Widget _buildBodyByRole() {
    String currentRole = widget.role.toLowerCase();
    if (currentRole == 'doctor') {
      return _buildDoctorDashboard();
    } else {
      return _buildPacienteDashboard();
    }
  }

  Widget _buildDoctorDashboard() {
    var proximaCita = _dashboard?['proxima_cita'];
    var ultimaOpinion = _dashboard?['ultima_review'];
    var ultimaPregunta = _dashboard?['ultima_question'];

    String textoCita = "Sin citas próximas";
    if (proximaCita != null) {
      String nombrePaciente =
          proximaCita['paciente']['user']['name'] ?? 'Paciente';

      String hora = proximaCita['fecha_hora']
          .toString()
          .split(' ')[1]
          .substring(0, 5);
      textoCita = "$nombrePaciente - $hora";
    }

    String textoOpinion = "Aún no tienes opiniones";
    String autorOpinion = "Anónimo";
    String? fotoOpinion;
    String? calificacionOpinion;

    if (ultimaOpinion != null) {
      textoOpinion = ultimaOpinion['contenido'] ?? '';
      autorOpinion = ultimaOpinion['autor']?['name'] ?? 'Anónimo';
      fotoOpinion = ultimaOpinion['autor']?['foto'];
      calificacionOpinion = ultimaOpinion['calificacion']?.toString();
    }

    String textoPregunta = "Aún no tienes preguntas";
    String autorPregunta = "Anónimo";
    String? fotoPregunta;

    if (ultimaPregunta != null) {
      textoPregunta = ultimaPregunta['contenido'] ?? '';
      autorPregunta = ultimaPregunta['autor']?['name'] ?? 'Anónimo';
      fotoPregunta = ultimaPregunta['autor']?['foto'];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Panel Médico",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MiTema.azulOscuro
              ,
            ),
          ),
          Text(
            "Bienvenido, Dr. ${widget.userName}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),

          const Text(
            "Acciones Rápidas",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  "Agenda",
                  BootstrapIcons.calendar2_fill,
                  MiTema.azulOscuro,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildQuickAction(
                  "Mensajes",
                  BootstrapIcons.chat_fill,
                  MiTema.azulOscuro,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            "Resumen del día",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildDate(
            "Siguiente cita",
            textoCita,
            BootstrapIcons.calendar3,
            MiTema.azulOscuro,
          ),
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
    List<dynamic> especialidadesDashboard = _dashboard?['especialidades'] ?? [];
    List<dynamic> rutasDashboard = _dashboard?['rutas'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, ${widget.userName}",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
          ),
          const Text(
            "Encuentra lo que buscas, aquí mismo.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),

          _buildMobileSearchCard(_listaEspecialidades),

          const SizedBox(height: 35),

          _buildSeccionEspecialidades(especialidadesDashboard),
          
          const SizedBox(height: 35),
          
          _buildMapaUbicaciones(rutasDashboard),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
    String imageprefix = 'http://127.0.0.1:8000/storage/';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MiTema.azulOscuro.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(headerIcon, color: MiTema.azulOscuro, size: 22),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$content"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              (authorPhoto != null && authorPhoto.isNotEmpty)
                              ? NetworkImage(
                                  imageprefix + authorPhoto,
                                )
                              : null,
                          child: (authorPhoto == null || authorPhoto.isEmpty)
                              ? Text(
                                  authorName.isNotEmpty
                                      ? authorName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    if (rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Text(
                              rating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ],
                        ),
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
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildMobileSearchCard(List<Especialidades> especialidades) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nombre, clínica o síntoma...",
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF5F7F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
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
                    items: especialidades.map((e) {
                      return DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.nombre, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSpecialty = val.toString()),
                  ),
                ),
              ],
              ],
            ),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  String textoBusqueda = _searchController.text.trim();
                  
                  // NAVEGACIÓN REAL
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusquedaResultados(
                        query: textoBusqueda,
                        type: _selectedRole,
                        especialidadId: _selectedSpecialty,
                      ),
                    ),
                  );
                },
                icon: const Icon(BootstrapIcons.search, color: Colors.white, size: 18),
                label: const Text("Buscar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MiTema.azulOscuro,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                ),
              ),
            )
          ],
        ),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(50),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          hint: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(hint, style: const TextStyle(color: Colors.black54), overflow: TextOverflow.ellipsis)),
            ],
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item.value,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: MiTema.azulOscuro),
                  const SizedBox(width: 8),
                  Expanded(child: item.child),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSeccionEspecialidades(List<dynamic> especialidades) {
    if (especialidades.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
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
              int count = esp['doctors']?.length ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 10, bottom: 5),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(esp['nombre'] ?? '', style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: MiTema.azulOscuro.withOpacity(0.1), shape: BoxShape.circle),
                      child: Text(count.toString(), style: TextStyle(color: MiTema.azulOscuro, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 25),

        ...especialidades.map((esp) {
          List<dynamic> doctores = esp['doctors'] ?? [];
          if (doctores.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esp['nombre'], 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: doctores.length,
                  itemBuilder: (context, index) {
                    var doctor = doctores[index];
                    String docName = doctor['user']?['name'] ?? 'Doctor';
                    String? docFoto = doctor['user']?['foto'];
                    String imgUrl = docFoto != null ? '${Globals.webUrl}/storage/$docFoto' : '';

                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 15, bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                            backgroundImage: docFoto != null ? NetworkImage(imgUrl) : null,
                            child: docFoto == null
                                ? Text(docName[0].toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MiTema.azulOscuro))
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            docName.startsWith("Dr") ? docName : "Dr. $docName",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(esp['nombre'], style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Doctores docMapeado = Doctores.fromJson(doctor);
                                Get.to(() => DoctorDetailsView(doctor: docMapeado));
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: MiTema.azulOscuro),
                                foregroundColor: MiTema.azulOscuro,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text("Ver Perfil", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          )
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
      ],
    );
  }

  Widget _buildMapaUbicaciones(List<dynamic> rutas) {
    if (rutas.isEmpty) return const SizedBox.shrink();

    // 1. Preparamos los marcadores para el mapa
    Set<Marker> markers = rutas.map((ruta) {
      double lat = double.tryParse(ruta['latitud']?.toString() ?? '0') ?? 0;
      double lng = double.tryParse(ruta['longitud']?.toString() ?? '0') ?? 0;
      return Marker(
        markerId: MarkerId(ruta['id'].toString()),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: ruta['name'] ?? 'Clínica', 
          snippet: (ruta['role'] ?? '').toString().toUpperCase()
        ),
      );
    }).toSet();

    // Centro inicial (Ocosingo por defecto, o la primera ruta si existe)
    LatLng centroInicial = const LatLng(16.9084, -92.0977);
    if (rutas.isNotEmpty) {
      double lat = double.tryParse(rutas[0]['latitud']?.toString() ?? '16.9084') ?? 16.9084;
      double lng = double.tryParse(rutas[0]['longitud']?.toString() ?? '-92.0977') ?? -92.0977;
      centroInicial = LatLng(lat, lng);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Clínicas y Farmacias en tu zona",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Descubre a los profesionales de la salud cerca de ti.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),
        
        // 2. El Mapa
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: centroInicial, zoom: 14),
              markers: markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                mapController = controller; // Vinculamos tu controlador global
              },
            ),
          ),
        ),
        
        const SizedBox(height: 15),

        // 3. Matriz Horizontal de Tarjetas
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              var ruta = rutas[index];
              String nombre = ruta['name'] ?? 'Desconocido';
              String role = ruta['role'] ?? '';
              String? foto = ruta['foto'];
              String imgUrl = foto != null ? '${Globals.webUrl}/storage/$foto' : '';
              
              double lat = double.tryParse(ruta['latitud']?.toString() ?? '0') ?? 0;
              double lng = double.tryParse(ruta['longitud']?.toString() ?? '0') ?? 0;

              return GestureDetector(
                onTap: () {
                  // Al tocar la tarjeta, el mapa vuela a esa coordenada (Igual que centrar() en JS)
                  mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
                },
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 15, bottom: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: foto != null ? NetworkImage(imgUrl) : null,
                        backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                        child: foto == null 
                            ? Icon(role == 'doctor' ? Icons.person : Icons.local_pharmacy, color: MiTema.azulOscuro) 
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(role.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildSectionTitle(String title) {
  //   return Text(
  //     title,
  //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //   );
  // }

  // Widget _buildServiceRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     children: [
  //       _buildServiceIcon(MagicoonFilled.stethoscope, "Doctores"),
  //       _buildServiceIcon(MagicoonFilled.chatDots, "Mensajes"),
  //       _buildServiceIcon(Icons.history, "Historial"),
  //     ],
  //   );
  // }

  // Widget _buildSpecialtiesBadges(List<dynamic> especialidades) {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: especialidades.map((esp) {
  //         int count = esp['doctors']?.length ?? 0;
  //         return Container(
  //           margin: const EdgeInsets.only(right: 10),
  //           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(30),
  //             border: Border.all(color: Colors.grey.shade200),
  //           ),
  //           child: Row(
  //             children: [
  //               const Icon(BootstrapIcons.star_fill, color: Colors.amber, size: 14),
  //               const SizedBox(width: 8),
  //               Text(esp['nombre'], style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold)),
  //               const SizedBox(width: 8),
  //               Container(
  //                 padding: const EdgeInsets.all(6),
  //                 decoration: BoxDecoration(color: MiTema.azulOscuro.withOpacity(0.1), shape: BoxShape.circle),
  //                 child: Text(count.toString(), style: TextStyle(color: MiTema.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
  //               )
  //             ],
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }
 
  // Widget _buildDoctorsList(List<dynamic> especialidades) {
  //   String imageprefix = '${Globals.webUrl}/storage/';
  //   return Column(
  //     children: especialidades.map((esp) {
  //       List<dynamic> doctores = esp['doctors'] ?? [];
  //       if (doctores.isEmpty) return const SizedBox.shrink();
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(esp['nombre'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)),
  //               const Text("Ver todos >", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
  //             ],
  //           ),
  //           const SizedBox(height: 15),
  //           SizedBox(
  //             height: 220,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: doctores.length,
  //               itemBuilder: (context, index) {
  //                 var doctor = doctores[index];
  //                 String docName = doctor['user']['name'] ?? 'Doctor';
  //                 String? docFoto = doctor['user']['foto'];
  //                 return Container(
  //                   width: 160,
  //                   margin: const EdgeInsets.only(right: 15, bottom: 10),
  //                   padding: const EdgeInsets.all(15),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(20),
  //                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
  //                   ),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       CircleAvatar(
  //                         radius: 35,
  //                         backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
  //                         backgroundImage: docFoto != null ? NetworkImage(imageprefix + docFoto) : null,
  //                         child: docFoto == null
  //                             ? Text(docName[0].toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MiTema.azulOscuro))
  //                             : null,
  //                       ),
  //                       const SizedBox(height: 10),
  //                       Text(
  //                         "Dr. $docName",
  //                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //                         textAlign: TextAlign.center,
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       const SizedBox(height: 5),
  //                       Text(esp['nombre'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
  //                       const Spacer(),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: ElevatedButton(
  //                           onPressed: () {},
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: MiTema.azulOscuro,
  //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //                             padding: const EdgeInsets.symmetric(vertical: 8),
  //                             elevation: 0,
  //                           ),
  //                           child: const Text("Ver Perfil", style: TextStyle(color: Colors.white, fontSize: 12)),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //         ],
  //       );
  //     }).toList(),
  //   );
  // }

  // Widget _buildServiceIcon(IconData icon, String label) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(15),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           shape: BoxShape.circle,
  //           boxShadow: [
  //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
  //           ],
  //         ),
  //         child: Icon(icon, color: MiTema.azulOscuro, size: 29),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(label, style: const TextStyle(fontSize: 12)),
  //     ],
  //   );
  // }

}
  // void _showChatbot(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yimini or chatyipiti...")));
  // }