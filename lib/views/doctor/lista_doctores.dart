import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';

class ListaDoctoresView extends StatelessWidget {
  final List<Doctores> doctores;
  final bool cargando;

  const ListaDoctoresView({
    super.key, 
    required this.doctores, 
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
    
    if (doctores.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay doctores registrados.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
      itemCount: doctores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18), 
      itemBuilder: (context, index) {
        final doctor = doctores[index];
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
                Get.to(() => DoctorDetailsView(doctor: doctor));
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
                          doctor.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person, size: 50, color: Colors.grey),
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
                    // Información del doctor
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              for (int i = 0; i < 5; i++)
                                Icon(
                                  i < (doctor.promedio ?? 0).round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.promedio?.toStringAsFixed(1) ?? '0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            doctor.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MiTema.azulOscuro,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Especialidad
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_services,
                                    color: MiTema.azulOscuro,
                                    size: 16, 
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      doctor.especialidad,
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
                              const SizedBox(height: 6),
                              // Horario
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: MiTema.azulOscuro,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${doctor.horarioentrada}:00 - ${doctor.horariosalida}:00 hrs',
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
                              // Precio
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: MiTema.azulOscuro,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${doctor.costos.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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