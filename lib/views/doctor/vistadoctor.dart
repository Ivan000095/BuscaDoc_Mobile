import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/url_helper.dart';
import 'package:buscadoc_mobile/views/doctor/agendar_cita.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/views/chat/vista_chat.dart';
import 'package:buscadoc_mobile/model/contactos.dart';
import 'package:buscadoc_mobile/services/comment_service.dart';
import 'package:buscadoc_mobile/views/comments/comment_dialog.dart';
import 'package:buscadoc_mobile/views/comments/replies_view.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailsView extends StatefulWidget {
  final Doctores doctor;

  const DoctorDetailsView({super.key, required this.doctor});

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  
  // Función para abrir Google Maps con coordenadas reales
  Future<void> _abrirMapa() async {
    if (widget.doctor.latitud != null && widget.doctor.longitud != null) {
      final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${widget.doctor.latitud},${widget.doctor.longitud}";
      final Uri url = Uri.parse(googleMapsUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Error", "No se pudo abrir el mapa", backgroundColor: Colors.white);
      }
    } else {
      Get.snackbar("Ubicación no disponible", "El doctor no cuenta con coordenadas.", backgroundColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // APPBAR CON IMAGEN
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: MiTema.azulOscuro,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(MagicoonFilled.angleLeft, color: Colors.white, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(doctor.image, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black45],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CONTENIDO
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -35, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7F9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      
                      Row(   
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.nombre.startsWith("Dr") ? doctor.nombre : "Dr. ${doctor.nombre}",
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: MiTema.azulOscuro, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.especialidad,
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          _buildRating(doctor.promedio ?? 0),
                        ],
                      ),
                      
                      const SizedBox(height: 25),

                      // BOTONES DE ACCIÓN RÁPIDA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickAction(MagicoonFilled.map, "Mapa", Colors.blue, _abrirMapa),
                          _buildQuickAction(MagicoonFilled.phone, "Llamar", Colors.green, () {
                             if (doctor.telefono.isNotEmpty) UrlHelper.makePhoneCall(doctor.telefono);
                          }),
                          _buildQuickAction(MagicoonFilled.chat, "Mensaje", Colors.orange, () {
                             Get.to(() => VistaChatView(contacto: ContactoChat(
                                id: doctor.idUsuario.toString(),
                                rol: doctor.rol,
                                nombre: doctor.nombre,
                                fotoUrl: doctor.image,
                                especialidad: doctor.especialidad,
                             )));
                          }),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // ACERCA DE
                      const Text('Acerca del doctor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Text(
                        doctor.descripcion.isNotEmpty ? doctor.descripcion : "Especialista médico altamente calificado en Ocosingo, Chiapas.",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6),
                      ),

                      const SizedBox(height: 35),

                      // TABLA DE HORARIOS (NATIVO EN VISTA)
                      const Text('Horario de atención', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                        ),
                        child: Column(
                          children: [
                            _buildScheduleRow("Lunes - Viernes", "${doctor.horarioentrada} - ${doctor.horariosalida} hrs"),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF0F0F0))),
                            _buildScheduleRow("Sábados", "09:00 - 14:00 hrs"),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF0F0F0))),
                            _buildScheduleRow("Domingos", "Cerrado", isClosed: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      _buildReviewsSection(context, doctor.idUsuario),
                      const SizedBox(height: 120), // Padding para el botón fijo
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTÓN PRINCIPAL
          Positioned(
            bottom: 25, left: 20, right: 20,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)]),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: MiTema.azulOscuro.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () => Get.to(() => AgendarCitaPage(doctor: doctor)),
                icon: const Icon(MagicoonFilled.calendar, color: Colors.white, size: 20),
                label: const Text("AGENDAR CITA AHORA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String day, String hour, {bool isClosed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(MagicoonRegular.clock, size: 16, color: isClosed ? Colors.grey : MiTema.azulOscuro),
            const SizedBox(width: 10),
            Text(day, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        Text(
          hour, 
          style: TextStyle(color: isClosed ? Colors.red.shade400 : MiTema.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14)
        ),
      ],
    );
  }

  Widget _buildRating(double promedio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(MagicoonFilled.star, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 6),
          Text(promedio.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, int doctorUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reseñas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            FutureBuilder<bool>(
              future: CommentService().canUserReview(doctorUserId: doctorUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final canReview = snapshot.data ?? false;

                if (canReview) {
                  return TextButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => CommentDialog(
                          destinatarioId: doctorUserId,
                          onCommentAdded: () {
                            Get.back(result: true);
                          },
                        ),
                      );
                      
                      if (result == true) {
                        setState(() {});
                        Get.snackbar('Éxito', 'Tu reseña se publicó correctamente');
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Reseñar'),
                    style: TextButton.styleFrom(foregroundColor: MiTema.azulOscuro),
                  );
                } else {
                  return Tooltip(
                    message: 'Solo puedes reseñar después de tener una cita con este doctor',
                    waitDuration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'Cita requerida',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: CommentService().getComments(userId: doctorUserId, tipo: 'resena'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data?['success'] != true) {
              return _buildEmptyReviews('No hay reseñas aún. ¡Sé el primero en opinar!');
            }
            final data = snapshot.data!;
            final reviews = data['data'] as List<dynamic>;
            final promedio = data['meta']?['promedio'] ?? 0.0;
            final totalResenas = data['meta']?['total_resenas'] ?? 0;

            if (reviews.isEmpty) {
              return _buildEmptyReviews('Aún no hay reseñas. ¡Sé el primero en opinar!');
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promedio.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < promedio.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          Text(
                            '$totalResenas reseña${totalResenas != 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          Get.snackbar('Info', 'Mostrando $totalResenas reseñas');
                        },
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...reviews.map((review) => _buildReviewCard(review, context)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyReviews(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic review, BuildContext context) {
    final autor = review['autor'] ?? {};
    final calificacion = review['calificacion'] as int?;
    final commentId = review['id'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: autor['foto'] != null
                    ? NetworkImage('${Globals.webUrl}/storage/${autor['foto']}')
                    : null,
                child: autor['foto'] == null
                    ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      autor['name'] ?? 'Usuario anónimo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review['created_at']),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              if (calificacion != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < calificacion ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['contenido'] ?? '',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepliesView(
                      commentId: commentId,
                      comment: review,
                    ),
                  ),
                );
              },
              child: Text(
                'Ver respuestas →',
                style: TextStyle(
                  fontSize: 12, 
                  color: MiTema.azulOscuro, 
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'Hace ${difference.inMinutes} min';
        }
        return 'Hace ${difference.inHours} h';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} d';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateString;
    }
  }
}