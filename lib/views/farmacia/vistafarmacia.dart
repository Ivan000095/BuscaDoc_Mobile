import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/url_helper.dart';
import 'package:buscadoc_mobile/services/comment_service.dart';
import 'package:buscadoc_mobile/views/comments/comment_dialog.dart';
import 'package:buscadoc_mobile/views/comments/replies_view.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class FarmaciaDetailsView extends StatefulWidget {
  final Farmacia farmacia;

  const FarmaciaDetailsView({super.key, required this.farmacia});

  @override
  State<FarmaciaDetailsView> createState() => _FarmaciaDetailsViewState();
}

class _FarmaciaDetailsViewState extends State<FarmaciaDetailsView> {
  @override
  Widget build(BuildContext context) {
    final farmacia = widget.farmacia;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: MiTema.azulOscuro,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (farmacia.imagen != null && farmacia.imagen!.isNotEmpty)
                    Image.network(
                      farmacia.imagen!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.local_pharmacy, size: 100, color: Colors.grey[600]),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.local_pharmacy, size: 100, color: Colors.grey[600]),
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
                            Colors.black.withOpacity(0.7),
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
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    farmacia.nombre,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: MiTema.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (farmacia.responsableNombre != null)
                    Text(
                      'Responsable: ${farmacia.responsableNombre}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactItem(
                        icon: Icons.location_on,
                        label: 'Ubicación',
                        onTap: () => UrlHelper.openMaps(farmacia.latitud, farmacia.longitud),
                      ),
                      _buildContactItem(
                        icon: Icons.phone,
                        label: 'Núm. Tel.',
                        onTap: () {
                          if (farmacia.telefono != 'No registrado') {
                            UrlHelper.makePhoneCall(farmacia.telefono);
                          } else {
                            Get.snackbar('Sin teléfono', 'Esta farmacia no tiene número registrado.');
                          }
                        },
                      ),
                      _buildContactItem(
                        icon: Icons.schedule,
                        label: 'Horarios',
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Horario de Atención'),
                              content: Text(
                                '${farmacia.horarioEntrada} - ${farmacia.horarioSalida}',
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
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // ✅ Abrir diálogo para crear reseña (sin validación de cita para farmacias)
                            showDialog(
                              context: context,
                              builder: (context) => CommentDialog(
                                destinatarioId: farmacia.idUsuario, // ✅ Usar farmacia.id (user_id)
                                onCommentAdded: () {
                                  setState(() {}); // ✅ Refrescar vista
                                  Get.back();
                                  Get.snackbar('Éxito', 'Tu reseña se publicó correctamente');
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MiTema.azulOscuro,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Reseñar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.snackbar(
                              'Reportar',
                              'Función de reporte próximamente',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: MiTema.azulOscuro, width: 2),
                            foregroundColor: MiTema.azulOscuro,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Reportar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // ✅ SECCIÓN DE RESEÑAS DINÁMICAS
                  _buildReviewsSection(context, farmacia.idUsuario),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MiTema.azulOscuro.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MiTema.azulOscuro, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ SECCIÓN DE RESEÑAS (igual que en doctores, pero sin validación de cita)
  Widget _buildReviewsSection(BuildContext context, int farmaciaUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reseñas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // ✅ Abrir diálogo para crear reseña (sin validación de cita para farmacias)
                showDialog(
                  context: context,
                  builder: (context) => CommentDialog(
                    destinatarioId: farmaciaUserId,
                    onCommentAdded: () {
                      setState(() {});
                      Get.back();
                      Get.snackbar('Éxito', 'Tu reseña se publicó correctamente');
                    },
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
              style: TextButton.styleFrom(foregroundColor: MiTema.azulOscuro),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        FutureBuilder<Map<String, dynamic>>(
          future: CommentService().getComments(userId: farmaciaUserId, tipo: 'resena'),
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
                // Resumen de calificación
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
                
                // Lista de reseñas
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

  // ✅ TARJETA DE RESEÑA (igual que en doctores)
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
          
          // Botón para ver respuestas
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