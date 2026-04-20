import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/url_helper.dart';
import 'package:buscadoc_mobile/views/doctor/citas.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/views/chat/vista_chat.dart';
import 'package:buscadoc_mobile/model/contactos.dart';
import 'package:buscadoc_mobile/services/comment_service.dart';
import 'package:buscadoc_mobile/views/comments/comment_dialog.dart';
import 'package:buscadoc_mobile/views/comments/replies_view.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class DoctorDetailsView extends StatefulWidget {
  final Doctores doctor;

  const DoctorDetailsView({super.key, required this.doctor});

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: MiTema.azulOscuro,
                leading: IconButton(
                  icon: const Icon(MagicoonFilled.angleLeft, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        doctor.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -25, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.nombre.startsWith("Dr") ? doctor.nombre : "Dr. ${doctor.nombre}",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: MiTema.azulOscuro,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  doctor.especialidad,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildRating(doctor.promedio ?? 0),
                        ],
                      ),
                      
                      const SizedBox(height: 35),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContactItem(
                            icon: MagicoonFilled.map,
                            label: 'Ubicación',
                            onTap: () => Get.snackbar('Mapa', 'Abriendo ubicación...'),
                          ),
                          _buildContactItem(
                            icon: MagicoonFilled.phone,
                            label: 'Teléfono',
                            onTap: () {
                              if (doctor.telefono.isNotEmpty) {
                                UrlHelper.makePhoneCall(doctor.telefono);
                              } else {
                                Get.snackbar('Sin teléfono', 'El doctor no tiene número registrado.');
                              }
                            },
                          ),
                          _buildContactItem(
                            icon: MagicoonFilled.clock,
                            label: 'Horarios',
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Horario de Atención'),
                                  content: Text(
                                    '${doctor.horarioentrada}:00 - ${doctor.horariosalida}:00 hrs',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ContactoChat contactoTemporal = ContactoChat(
                                  id: doctor.idUsuario.toString(),
                                  rol: doctor.rol,
                                  nombre: doctor.nombre,
                                  fotoUrl: doctor.image,
                                  especialidad: doctor.especialidad,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaChatView(contacto: contactoTemporal),
                                  ),
                                );
                              },
                              icon: const Icon(MagicoonRegular.calendar, size: 20),
                              label: const Text('Agendar Cita', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MiTema.azulOscuro,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.snackbar('Reseñar', 'Función próximamente...');
                              },
                              icon: const Icon(MagicoonRegular.chatDots, size: 20),
                              label: const Text('Mensaje', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: MiTema.azulOscuro, width: 2),
                                foregroundColor: MiTema.azulOscuro,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        'Acerca del doctor',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        doctor.descripcion.isNotEmpty ? doctor.descripcion : "Este doctor aún no tiene una descripción detallada.",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
                      ),

                      const SizedBox(height: 40),
                      _buildReviewsSection(context, doctor.idUsuario),
                      const SizedBox(height: 80),
                    ],
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 8,
                shadowColor: MiTema.azulOscuro.withOpacity(0.5),
              ),
              onPressed: () => Get.to(() => AgendarCitaPage(doctor: doctor)),
              child: const Text(
                "AGENDAR CITA",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MiTema.azulOscuro.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MiTema.azulOscuro, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(double promedio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Text(
            promedio > 0 ? promedio.toStringAsFixed(1) : "0.0",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          const Icon(MagicoonFilled.star, color: Colors.amber, size: 18),
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