import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/views/doctor/citas.dart';

class DoctorDetailsView extends StatelessWidget {
  final Doctores doctor;
  
  // Simulamos una lista de comentarios para el diseño
  final List<Map<String, String>> comentariosMock = [
    {"user": "Paciente 1", "texto": "Excelente atención, muy profesional."},
    {"user": "Paciente 2", "texto": "Me gustó mucho cómo explicó el tratamiento."},
  ];

  DoctorDetailsView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: MiTema.azulOscuro,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    doctor.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 100)),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -10, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                doctor.nombre,
                                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            _buildRating(doctor.promedio ?? 0),
                          ],
                        ),
                        
                        Text(
                          doctor.especialidad,
                          style: GoogleFonts.poppins(fontSize: 16, color: MiTema.azulOscuro, fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _iconDetail(Icons.location_on, "Ubicación"),
                            _iconDetail(Icons.access_time, "Horarios"),
                            _iconDetail(Icons.calendar_month, "Días"),
                            _iconDetail(Icons.phone, "Teléfono"),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              _actionPill("Solicitar cita"),
                              _actionPill("Enviar mensaje"),
                              _actionPill("Reseñar"),
                              _actionPill("Reportar"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        Text("Acerca del doctor", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          doctor.descripcion,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.6),
                        ),

                        const SizedBox(height: 30),

                        Text("Comentarios", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildCommentsList(),
                        
                        const SizedBox(height: 100),

                        Text("Mapa del doctor", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildMap(doctor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MiTema.azulOscuro,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 10,
              ),
              onPressed: () => Get.to(() => AgendarCitaPage(doctor: doctor)),
              child: const Text("AGENDAR CONSULTA", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconDetail(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: MiTema.azulOscuro, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }


  Widget _actionPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: MiTema.azulOscuro,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRating(double promedio) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < promedio.round() ? Icons.star : Icons.star_border,
            color: MiTema.azulOscuro,
            size: 20,
          ),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (doctor.comentarios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "${doctor.nombre} aún no tiene reseñas.",
          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: doctor.comentarios.map((comentario) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: MiTema.azulOscuro,
              backgroundImage: comentario.foto != null && comentario.foto!.isNotEmpty
                  ? NetworkImage(comentario.foto!)
                  : null,
              child: comentario.foto == null || comentario.foto!.isEmpty
                  ? Text(
                      comentario.autor.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comentario.autor,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < 5; i++)
                              Icon(
                                i < comentario.calificacion.round() ? Icons.star : Icons.star_border,
                                color: MiTema.azulOscuro,
                                size: 14,
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      comentario.contenido, 
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comentario.fecha,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
  
  Widget _buildMap(Doctores doctor) {
    return Text('pene');
  }
}