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
          decoration: BoxDecoration(
            color: MiTema.blanco,
            borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.to(() => FarmaciaDetailsView(farmacia: farmacia));
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network( 
                          farmacia.imagen ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.local_pharmacy, size: 50, color: Colors.grey),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              for (int i = 0; i < 5; i++)
                                Icon(
                                  i < (farmacia.promedio ?? 0).round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              
                              const SizedBox(width: 4),
                              Text(
                                farmacia.promedio?.toStringAsFixed(1) ?? '0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: MiTema.azulOscuro,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${farmacia.horarioEntrada} - ${farmacia.horarioSalida}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: MiTema.azulOscuro,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  farmacia.telefono,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: MiTema.azulOscuro,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  farmacia.rfc ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
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
              ),
            ),
          ),
        );
      },
    );
  }
}