import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/url_helper.dart';
import 'package:buscadoc_mobile/views/doctor/citas.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/views/chat/vista_chat.dart';
import 'package:buscadoc_mobile/model/contactos.dart';

class DoctorDetailsView extends StatelessWidget {
  final Doctores doctor;

  const DoctorDetailsView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo como en farmacia
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. APP BAR CON IMAGEN Y DEGRADADO (Estilo Farmacia)
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

              // 2. CUERPO DEL DETALLE
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -25, 0), // Solapamos un poco la imagen
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      
                      // Nombre y Calificación
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
                            onTap: () {
                              // Aquí puedes abrir mapas si tienes lat/lng
                              Get.snackbar('Mapa', 'Abriendo ubicación...');
                            },
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
                              icon: const Icon(MagicoonRegular.chatDots, size: 20),
                              label: const Text('Mensaje', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
                              icon: const Icon(MagicoonRegular.star, size: 20),
                              label: const Text('Reseñar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

                      const Text(
                        'Reseñas',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),
                      _buildCommentsList(),

                      const SizedBox(height: 120),
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
                "AGENDAR CONSULTA",
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

  Widget _buildCommentsList() {
    if (doctor.comentarios.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          "Aún no tiene reseñas.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: doctor.comentarios.map((comentario) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: MiTema.azulOscuro,
              radius: 22,
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
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          comentario.autor,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < comentario.calificacion.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comentario.contenido, 
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comentario.fecha,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}