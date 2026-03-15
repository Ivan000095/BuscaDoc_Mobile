import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class HomeDashboard extends StatefulWidget {
  final String role;
  final String userName;

  const HomeDashboard({super.key, required this.role, required this.userName});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late GoogleMapController mapController;
  final LatLng _centroOcosingo = const LatLng(16.9084, -92.0977);

  bool _cargando = true;
  Map<String, dynamic>? _dashboard;

  @override
  void initState() {
    super.initState();
    _showDashboardData();
  }

  Future<void> _showDashboardData() async {
    String? token = await Usuario.obtenerToken();

    if (token == null) {
      setState(() => _cargando = false);
      return;
    }

    var response = await Usuario.dashboard(token);

    if (response['success']) {
      setState(() {
        _dashboard = response['data'];
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
      print("Error de API: ${response['message']}");
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
              color: MiTema.azulOscuro,
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
                  Icons.calendar_month,
                  MiTema.azulOscuro,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildQuickAction(
                  "Mensajes",
                  Icons.chat_bubble,
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
            Icons.person,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, ${widget.userName}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            "¿Qué necesitas hoy?",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar cardiólogo, pediatra...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("Matriz de ubicaciones"),
          const SizedBox(height: 10),

          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _centroOcosingo,
                  zoom: 13,
                ),
                onMapCreated: (controller) => mapController = controller,
              ),
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("Servicios"),
          const SizedBox(height: 15),
          _buildServiceRow(),
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

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
}

Widget _buildServiceRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildServiceIcon(Icons.medical_information, "Doctores"),
      _buildServiceIcon(Icons.chat, "Mensajes"),
      _buildServiceIcon(Icons.history, "Historial"),
    ],
  );
}

Widget _buildServiceIcon(IconData icon, String label) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Icon(icon, color: MiTema.azulOscuro),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

  // void _showChatbot(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yimini or chatyipiti...")));
  // }