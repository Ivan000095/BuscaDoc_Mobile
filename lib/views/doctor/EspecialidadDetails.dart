import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/doctores.dart'; 
import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';
import 'package:magicoon_icons/magicoon.dart';

class EspecialidadDetalleView extends StatelessWidget {
  final dynamic especialidad;

  const EspecialidadDetalleView({super.key, required this.especialidad});

  @override
  Widget build(BuildContext context) {
    final doctoresRaw = especialidad.doctores ?? [];
    
    // 👇 1. MAPEAR Y ORDENAR UNA SOLA VEZ
    List<Doctores> doctoresOrdenados = doctoresRaw.map<Doctores?>((d) {
      try { 
        return Doctores.fromJson(d); 
      } catch (_) { 
        return null; 
      }
    }).whereType<Doctores>().toList(); // .whereType elimina los nulos automáticamente

    // Ordenamos de mayor a menor calificación
    doctoresOrdenados.sort((a, b) => (b.promedio ?? 0.0).compareTo(a.promedio ?? 0.0));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: MiTema.azulOscuro),
        title: Text(
          especialidad.nombre,
          style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER DE LA ESPECIALIDAD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: MiTema.azulOscuro.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(MagicoonFilled.star, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Especialidad en",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                        Text(
                          especialidad.nombre,
                          style: TextStyle(color: MiTema.azulOscuro, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${doctoresOrdenados.length} doctores disponibles",
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Doctores Especialistas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            // --- LISTA DE DOCTORES ---
            if (doctoresOrdenados.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("No hay doctores en esta especialidad.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Wrap(
                spacing: 15,
                runSpacing: 15,
                // 👇 2. USAMOS DIRECTAMENTE EL OBJETO 'Doctores' SIN VOLVER A PARSEAR
                children: doctoresOrdenados.map<Widget>((doctor) {
                  
                  final docName = doctor.nombre;
                  final imgUrl = doctor.image;
                  final bool tieneFoto = imgUrl.isNotEmpty && !imgUrl.contains('placeholder');

                  // --- CÁLCULO DE HORA ---
                  final bool esDescanso = doctor.horarioentrada == 'Descanso' || doctor.horarioentrada.isEmpty;
                  bool estaDisponibleAhora = false;

                  if (!esDescanso) {
                    try {
                      final partesEntrada = doctor.horarioentrada.split(':');
                      final partesSalida = doctor.horariosalida.split(':');
                      if (partesEntrada.length >= 2 && partesSalida.length >= 2) {
                        int hE = int.parse(partesEntrada[0]);
                        int mE = int.parse(partesEntrada[1]);
                        int hS = int.parse(partesSalida[0]);
                        int mS = int.parse(partesSalida[1]);
                        
                        TimeOfDay ahora = TimeOfDay.now();
                        double nowVal = ahora.hour + (ahora.minute / 60.0);
                        if (nowVal >= (hE + (mE / 60.0)) && nowVal <= (hS + (mS / 60.0))) {
                          estaDisponibleAhora = true;
                        }
                      }
                    } catch (_) {}
                  }

                  // --- COLORES DE LA PÍLDORA ---
                  Color bgColor;
                  Color textColor;
                  String textoPildora;
                  IconData iconoPildora = MagicoonFilled.clock;

                  if (esDescanso) {
                    bgColor = Colors.red.shade50;
                    textColor = Colors.red.shade700;
                    textoPildora = 'Hoy no atiende';
                    iconoPildora = MagicoonFilled.moon;
                  } else if (!estaDisponibleAhora) {
                    bgColor = Colors.orange.shade50;
                    textColor = Colors.orange.shade800;
                    textoPildora = 'No disponible ahora';
                  } else {
                    bgColor = Colors.green.shade50;
                    textColor = Colors.green.shade700;
                    textoPildora = '${doctor.horarioentrada} - ${doctor.horariosalida}';
                  }

                  return Container(
                    width: (Get.width / 2) - 28, 
                    height: 220, 
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                          backgroundImage: tieneFoto ? NetworkImage(imgUrl) : null,
                          child: !tieneFoto
                              ? Text(
                                  docName.isNotEmpty ? docName[0].toUpperCase() : 'D',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          docName.startsWith("Dr") ? docName : "Dr. $docName",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(MagicoonFilled.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              (doctor.promedio ?? 0.0).toStringAsFixed(1),
                              style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(iconoPildora, size: 10, color: textColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  textoPildora,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Get.to(() => DoctorDetailsView(doctor: doctor)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: MiTema.azulOscuro),
                              foregroundColor: MiTema.azulOscuro,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text("Ver Perfil", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}