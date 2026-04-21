import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/agendar_controller.dart';
import 'package:magicoon_icons/magicoon.dart';

class AgendarCitaPage extends StatelessWidget {
  final Doctores doctor;

  const AgendarCitaPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final AgendarController controller = Get.put(AgendarController(doctorId: doctor.id));
    
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Agendar Cita", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TARJETA DEL DOCTOR (Rediseñada)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(25), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: MiTema.azulOscuro.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 35, 
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: NetworkImage(doctor.image),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: MiTema.azulOscuro.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                "Especialista", 
                                style: TextStyle(color: MiTema.azulOscuro, fontSize: 10, fontWeight: FontWeight.bold)
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctor.nombre.startsWith("Dr") ? doctor.nombre : "Dr. ${doctor.nombre}", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.especialidad, 
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                _buildInputLabel("¿Para quién es la cita?"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(15), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.selectedExpediente.value,
                      hint: Text("Selecciona un paciente", style: TextStyle(color: Colors.grey.shade400)),
                      icon: const Icon(MagicoonRegular.angleDown, size: 20),
                      items: controller.expedientes.map((exp) {
                        return DropdownMenuItem<String>(
                          value: exp['id'].toString(),
                          child: Row(
                            children: [
                              const Icon(MagicoonFilled.user, color: Colors.grey, size: 18),
                              const SizedBox(width: 10),
                              Text(exp['nombre_completo'], style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => controller.selectedExpediente.value = val,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                _buildInputLabel("Fecha de la cita"),
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: MiTema.azulOscuro)), 
                        child: child!
                      ),
                    );
                    if (picked != null) controller.buscarHorarios(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(15), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedDate.value != null 
                            ? DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(controller.selectedDate.value!).capitalizeFirst! 
                            : "Selecciona un día en el calendario",
                          style: TextStyle(
                            color: controller.selectedDate.value != null ? Colors.black87 : Colors.grey.shade400, 
                            fontWeight: FontWeight.w600,
                            fontSize: 15
                          ),
                        ),
                        Icon(MagicoonFilled.calendar, color: controller.selectedDate.value != null ? MiTema.azulOscuro : Colors.grey.shade400, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                _buildInputLabel("Horario disponible"),
                controller.isFetchingSlots.value 
                  ? Center(child: Padding(padding: const EdgeInsets.all(30), child: CircularProgressIndicator(color: MiTema.azulOscuro)))
                  : controller.availableSlots.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          border: Border.all(color: Colors.grey.shade200)
                        ),
                        child: Column(
                          children: [
                            Icon(MagicoonRegular.clock, size: 40, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text(
                              controller.slotMessage.value, 
                              textAlign: TextAlign.center, 
                              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: controller.availableSlots.map((hora) {
                          bool isSelected = controller.selectedSlot.value == hora;
                          return ChoiceChip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              child: Text(hora),
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87, 
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                            ),
                            selected: isSelected,
                            selectedColor: MiTema.azulOscuro,
                            backgroundColor: Colors.white,
                            showCheckmark: false,
                            elevation: isSelected ? 3 : 0,
                            shadowColor: MiTema.azulOscuro.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), 
                              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200)
                            ),
                            onSelected: (selected) { if (selected) controller.selectedSlot.value = hora; },
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 35),

                // 5. MOTIVO
                _buildInputLabel("Motivo de la consulta"),
                TextField(
                  controller: controller.motivoCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Describe brevemente tus síntomas o el motivo de tu visita...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: MiTema.azulOscuro)),
                  ),
                ),
                
                const SizedBox(height: 120), // Margen para que se pueda hacer scroll hasta el fondo
              ],
            ),
          ),

          // BOTÓN FLOTANTE INFERIOR (DESAPARECE SI SE ABRE EL TECLADO)
          if (!isKeyboardOpen)
            Positioned(
              bottom: 25, left: 20, right: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(color: MiTema.azulOscuro.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: () => controller.confirmarCita(),
                  icon: const Icon(MagicoonFilled.checkCircle, color: Colors.white, size: 22),
                  label: const Text(
                    "CONFIRMAR CITA", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)
                  ),
                ),
              ),
            ),
          
          // OVERLAY DE CARGA ELEGANTE
          if (controller.isLoading.value)
            Container(
              color: Colors.white.withOpacity(0.8), 
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
                  child: CircularProgressIndicator(color: MiTema.azulOscuro),
                )
              )
            )
        ],
      )),
    );
  }

  // Widget de ayuda para los títulos de cada sección
  Widget _buildInputLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        texto, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
      ),
    );
  }
}