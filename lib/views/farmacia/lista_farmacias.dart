import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';

class ListaFarmaciasView extends StatelessWidget {
  const ListaFarmaciasView({super.key});

  @override
  Widget build(BuildContext context) {

    //PASGARRR: estos son datos simulados, los cambias después
    final List<Map<String, dynamic>> farmaciasMock = [
      {"nombre": "Farmacia San Pablo", "horario": "08:00 AM - 10:00 PM", "rating": 4.5, "distancia": "1.2 km"},
      {"nombre": "Farmacias del Ahorro", "horario": "24 Horas", "rating": 5.0, "distancia": "2.5 km"},
      {"nombre": "Farmacia Guadalajara", "horario": "07:00 AM - 11:00 PM", "rating": 3.8, "distancia": "3.0 km"},
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
      itemCount: farmaciasMock.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18), 
      itemBuilder: (context, index) {
        final farmacia = farmaciasMock[index];
        return Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                // PASGARRRR: Aquí va el Get.to(() => FarmaciaDetailsView(farmacia));
              },
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: MiTema.azulOscuro.withOpacity(0.1), // Fondo azul clarito
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                    child: Icon(Icons.local_pharmacy, size: 50, color: MiTema.azulOscuro),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              for (int i = 0; i < 5; i++)
                                Icon(
                                  i < farmacia['rating'].round() ? Icons.star : Icons.star_border,
                                  color: Colors.amber, // Estrellas doradas para farmacias
                                  size: 18
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                                  const SizedBox(width: 8),
                                  Text(farmacia['horario'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Text(farmacia['distancia'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            farmacia['nombre'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}