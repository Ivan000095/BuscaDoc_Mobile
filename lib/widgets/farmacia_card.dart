import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/views/farmacia/vistafarmacia.dart';
import 'package:buscadoc_mobile/utils/url_helper.dart';

class FarmaciaCard extends StatelessWidget {
  final Farmacia farmacia;

  const FarmaciaCard({super.key, required this.farmacia});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Get.to(() => FarmaciaDetailsView(farmacia: farmacia)),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGEN (Izquierda)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  farmacia.imagen ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(Icons.local_pharmacy, size: 40, color: Colors.grey[600]),
                  ),
                ),
              ),
              
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nombre Farmacia
                    Text(
                      farmacia.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MiTema.azulOscuro,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => UrlHelper.openMaps(farmacia.latitud, farmacia.longitud),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 5),
                          Text(
                            'Ubicación',
                            style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        Text(
                          'Horarios: ${farmacia.horarioEntrada} - ${farmacia.horarioSalida}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        Text(
                          'Núm. Tel.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          farmacia.telefono, 
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}