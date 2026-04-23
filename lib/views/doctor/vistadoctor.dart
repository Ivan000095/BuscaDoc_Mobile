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
                      Image.network(
                        doctor.image, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF5F7F9),
                          child: Icon(MagicoonFilled.user, size: 80, color: Colors.grey.shade300),
                        ),
                      ),
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAction(MagicoonFilled.map, "Mapa", MiTema.azulOscuro, _abrirMapa),
                          _buildQuickAction(MagicoonFilled.chat, "Mensaje", MiTema.azulOscuro, () {
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

                      const Text('Horarios de atención', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 15), 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: doctor.disponibilidades.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    "No hay horarios registrados",
                                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 190, 
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: 7, 
                                  itemBuilder: (context, index) {
                                    DateTime fechaActual = DateTime.now().add(Duration(days: index));
                                    int diaBusqueda = fechaActual.weekday == 7 ? 0 : fechaActual.weekday;
                                    
                                    var horariosDia = doctor.disponibilidades.where((d) {
                                      int diaD = int.tryParse(d['dia_semana'].toString()) ?? -1;
                                      return diaD == diaBusqueda;
                                    }).toList();

                                    horariosDia.sort((a, b) => a['hora_inicio'].toString().compareTo(b['hora_inicio'].toString()));

                                    String tituloDia;
                                    if (index == 0) tituloDia = "Hoy";
                                    else if (index == 1) tituloDia = "Mañana";
                                    else {
                                      const nombresDias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
                                      tituloDia = nombresDias[diaBusqueda];
                                    }

                                    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                                    String fechaStr = "${fechaActual.day} ${meses[fechaActual.month - 1]}";

                                    return Container(
                                      width: 90, 
                                      margin: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        children: [
                                          Text(
                                            tituloDia,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                              fontWeight: index < 2 ? FontWeight.w600 : FontWeight.normal, 
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fechaStr,
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                          ),
                                          const SizedBox(height: 15),

                                          if (horariosDia.isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 15),
                                              child: Text("-", style: TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.w300)),
                                            )
                                          else
                                            Expanded(
                                              child: SingleChildScrollView(
                                                physics: const BouncingScrollPhysics(),
                                                child: Column(
                                                  children: horariosDia.map((disp) {
                                                    String hInicio = disp['hora_inicio'].toString().substring(0, 5);
                                                    String hFin = disp['hora_fin'].toString().substring(0, 5);

                                                    return Container(
                                                      margin: const EdgeInsets.only(bottom: 10),
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: MiTema.azulOscuro.withOpacity(0.08), 
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            hInicio,
                                                            style: TextStyle(
                                                              color: MiTema.azulOscuro, 
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            "a $hFin",
                                                            style: TextStyle(
                                                              color: MiTema.azulOscuro.withOpacity(0.7), 
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      _buildReviewsSection(context, doctor.idUsuario),
                      const SizedBox(height: 120),
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
    
    final String fotoUrl = autor['foto'] != null 
        ? '${Globals.webUrl}/storage/${autor['foto']}' 
        : '';
    final String nombre = autor['name'] ?? 'Usuario anónimo';
    final String fecha = _formatDate(review['created_at']);
    final String contenido = review['contenido'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                child: fotoUrl.isEmpty
                    ? Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U', 
                        style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18)
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (calificacion != null) ...[
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < calificacion ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          // Puntito separador
                          Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            fecha,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (contenido.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F9), // Fondo gris muy suave
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100)
              ),
              child: Text(
                contenido,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
              ),
            ),
          ],
          
          // BOTÓN DE RESPUESTAS
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
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
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver respuestas',
                      style: TextStyle(fontSize: 12, color: MiTema.azulOscuro, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: MiTema.azulOscuro),
                  ],
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