import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/url_helper.dart';

class FarmaciaDetailsView extends StatelessWidget {
  final Farmacia farmacia;

  const FarmaciaDetailsView({super.key, required this.farmacia});
  @override
  Widget build(BuildContext context) {
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
                            Get.snackbar(
                              'Reseñar',
                              'Función de reseñas próximamente',
                              snackPosition: SnackPosition.BOTTOM,
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
                  const Text(
                    'Reseñas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...List.generate(3, (index) => _buildReviewCard(index)),
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
  Widget _buildReviewCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=${index + 10}',
            ),
            onBackgroundImageError: (_, __) {},
            child: Icon(Icons.person, color: Colors.grey[600]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Me gusto la forma que me atendio, muy profesional',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(5, (starIndex) => 
              Icon(
                Icons.star,
                size: 16,
                color: starIndex < 5 ? Colors.amber : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
}