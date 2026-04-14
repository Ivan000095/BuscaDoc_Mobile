import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/views/farmacia/vistafarmacia.dart';

class ListaFarmaciasView extends StatelessWidget {
  final List<Farmacia> farmacias;
  final bool cargando;

  const ListaFarmaciasView({
    super.key, 
    required this.farmacias, 
    required this.cargando
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Center(
        child: CircularProgressIndicator(
          color: MiTema.azulOscuro,
        ),
      );
    }
    
    if (farmacias.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay farmacias registradas.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
      itemCount: farmacias.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18), 
      itemBuilder: (context, index) {
        final farmacia = farmacias[index];
        return Container(
          height: 140,
          decoration: BoxDecoration(
            color: MiTema.blanco,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Get.to(() => FarmaciaDetailsView(farmacia: farmacia));
              },
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                      child: Image.network( 
                        farmacia.imagen ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.local_pharmacy, size: 50, color: Colors.grey),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.schedule, 
                                color: MiTema.azulOscuro, 
                                size: 14
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${farmacia.horarioEntrada} - ${farmacia.horarioSalida}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description, 
                                    color: MiTema.azulOscuro, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      farmacia.descripcion.isNotEmpty 
                                          ? farmacia.descripcion 
                                          : 'Sin descripción',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on, 
                                    color: MiTema.azulOscuro, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Ver mapa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: MiTema.azulOscuro, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      farmacia.telefono,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            farmacia.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MiTema.azulOscuro,
                            ),
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