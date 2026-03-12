import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';

class ListaDoctoresView extends StatelessWidget {
  // Ahora recibimos los datos desde el archivo VistaInicio
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
                Get.to(() => DoctorDetailsView(doctor: doctor));
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
                        doctor.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
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
                                  i < (doctor.promedio ?? 0).round() 
                                      ? Icons.star 
                                      : Icons.star_border,
                                  color: MiTema.azulOscuro, 
                                  size: 18
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.assignment_ind, color: MiTema.azulOscuro, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doctor.especialidad,
                                      style: TextStyle(
                                        fontSize: 13, 
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
                              Row(
                                children: [
                                  Icon(Icons.insert_drive_file_sharp, color: MiTema.azulOscuro, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doctor.descripcion,
                                      style: TextStyle(
                                        fontSize: 13, 
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
                            doctor.nombre,
                            style: TextStyle(
                              fontSize: 18,
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