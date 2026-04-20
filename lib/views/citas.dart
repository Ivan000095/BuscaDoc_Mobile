import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/citas_controller.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';


class MisCitasView extends StatelessWidget {
  final String role;
  
  // Inyectamos el controlador
  final CitasController controller = Get.put(CitasController());

  MisCitasView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Mis Citas Médicas", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: MiTema.azulOscuro));
        }

        if (controller.citasList.isEmpty) {
          return _buildEmptyState();
        }

        return Stack(
          children: [
            RefreshIndicator(
              color: MiTema.azulOscuro,
              onRefresh: () => controller.fetchCitas(),
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: controller.citasList.length,
                itemBuilder: (context, index) {
                  return _buildCitaCard(context, controller.citasList[index]);
                },
              ),
            ),
            
            // Overlay de carga si se está cancelando/aceptando algo
            if (controller.isActionLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator(color: MiTema.azulOscuro)),
              )
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text("No tienes citas registradas.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCitaCard(BuildContext context, Map<String, dynamic> cita) {
    DateTime fecha = DateTime.parse(cita['fecha']);
    String mes = DateFormat('MMM', 'es_ES').format(fecha).toUpperCase();
    String diaNum = DateFormat('dd').format(fecha);
    String diaAbrev = DateFormat('E', 'es_ES').format(fecha);
    
    String nombreMostrar = '';
    
    if (role == 'doctor') {
      if (cita['expediente'] != null && cita['expediente']['nombre_completo'] != null) {
        nombreMostrar = cita['expediente']['nombre_completo'];
      } else {
        nombreMostrar = 'Paciente';
      }
    } else {
      String docName = '';
      if (cita['doctor'] != null && cita['doctor']['user'] != null) {
        docName = cita['doctor']['user']['name'] ?? '';
      }
      nombreMostrar = "Dr. $docName";
    }
        
    String? fotoMostrar = role == 'doctor' ? null : cita['doctor']?['user']?['foto'];
    String subtitleMostrar = role == 'doctor' ? 'Paciente' : cita['doctor']?['especialidades']?[0]?['nombre'] ?? 'Especialista';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TICKET FECHA (Azul Navy)
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: MiTema.azulOscuro,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mes, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(diaNum, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  Text(diaAbrev, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            
            // INFORMACIÓN Y ACCIONES
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
                          backgroundImage: fotoMostrar != null ? NetworkImage('${Globals.webUrl}/storage/$fotoMostrar') : null,
                          child: fotoMostrar == null ? Icon(BootstrapIcons.person_fill, color: MiTema.azulOscuro) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(BootstrapIcons.clock_fill, size: 12, color: MiTema.azulOscuro),
                                  const SizedBox(width: 4),
                                  Text(cita['hora_inicio'].substring(0, 5), style: TextStyle(color: MiTema.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Text(nombreMostrar, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(subtitleMostrar, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildStatusArea(context, cita),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusArea(BuildContext context, Map<String, dynamic> cita) {
    var solicitudRecibida = cita['solicitud_recibida'];
    var solicitudEnviada = cita['solicitud_enviada'];
    

    if (solicitudRecibida != null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            const Text("¡Nueva propuesta de horario!", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.responderPropuesta(cita['id'], 'aceptar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0),
                    child: const Text("Aceptar", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _mostrarBottomSheetRechazo(context, cita['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
                    child: const Text("Rechazar", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }

    if (solicitudEnviada != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(50)),
        child: const Text("⏳ Esperando respuesta...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    }

    Color badgeColor = Colors.grey.shade200;
    Color textColor = Colors.grey.shade700;
    if (cita['estado'] == 'pendiente') { badgeColor = Colors.orange.shade100; textColor = Colors.orange.shade800; }
    else if (cita['estado'] == 'confirmada') { badgeColor = Colors.green.shade100; textColor = Colors.green.shade800; }
    else if (cita['estado'] == 'cancelada') { badgeColor = Colors.red.shade100; textColor = Colors.red.shade800; }

    bool canDelete = ['cancelada', 'rechazada', 'finalizada', 'no asistida'].contains(cita['estado']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Badge de Estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(50)),
          child: Text(cita['estado'].toString().toUpperCase(), style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        
        const SizedBox(width: 8), // Pequeño margen
        
        // Acciones dinámicas con Wrap para evitar Overflows
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0, // Espaciado horizontal entre botones
            runSpacing: -10, // Espaciado vertical si bajan a la otra línea
            children: [
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmarEliminacion(context, cita['id']),
                )
              else if (cita['estado'] == 'pendiente' || cita['estado'] == 'confirmada') ...[
                TextButton(
                  onPressed: () => _mostrarBottomSheetPropuesta(context, cita),
                  // Reducimos un puntito la fuente para que quepa mejor
                  child: const Text("Reprogramar", style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => _confirmarCancelacion(context, cita['id']),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }


  void _confirmarCancelacion(BuildContext context, int citaId) {
    Get.defaultDialog(
      title: "Cancelar Cita",
      middleText: "¿Estás seguro que deseas cancelar esta cita? Esta acción no se puede deshacer.",
      textConfirm: "Sí, cancelar",
      textCancel: "Cerrar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: MiTema.azulOscuro,
      onConfirm: () {
        Get.back(); // Cerrar dialog
        controller.cancelarCita(citaId);
      },
    );
  }

  void _confirmarEliminacion(BuildContext context, int citaId) {
    Get.defaultDialog(
      title: "Ocultar Cita",
      middleText: "¿Deseas eliminar este registro de tu historial?",
      textConfirm: "Eliminar",
      textCancel: "Cancelar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.eliminarCita(citaId);
      },
    );
  }

  void _mostrarBottomSheetRechazo(BuildContext context, int citaId) {
    final TextEditingController motivoCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rechazar Cambio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Por favor, indica brevemente por qué no puedes aceptar el nuevo horario:", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 15),
            TextField(
              controller: motivoCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe el motivo...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                onPressed: () {
                  if (motivoCtrl.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Debes escribir un motivo', backgroundColor: Colors.red.shade100);
                    return;
                  }
                  controller.responderPropuesta(citaId, 'rechazar', motivo: motivoCtrl.text.trim());
                },
                child: const Text("Confirmar Rechazo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarBottomSheetPropuesta(BuildContext context, Map<String, dynamic> cita) {
    // Variables locales reactivas para este modal
    final Rxn<DateTime> selectedDate = Rxn<DateTime>();
    final RxnString selectedSlot = RxnString();
    final TextEditingController motivoCtrl = TextEditingController();
    
    // Limpiamos los slots anteriores al abrir el modal
    controller.availableSlots.clear();
    controller.slotMessage("Elige una fecha para ver horarios disponibles");

    int doctorId = cita['doctor_id'] ?? cita['doctor']['id'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(BootstrapIcons.calendar_event, color: MiTema.azulOscuro),
                const SizedBox(width: 10),
                const Text("Proponer Nuevo Horario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // 1. Selector de Fecha
            const Text("1. Selecciona la nueva fecha", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(primary: MiTema.azulOscuro),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  selectedDate.value = picked;
                  selectedSlot.value = null; // Reiniciar slot seleccionado
                  String fechaFormateada = DateFormat('yyyy-MM-dd').format(picked);
                  controller.fetchDisponibilidad(doctorId, fechaFormateada);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate.value != null ? DateFormat('dd / MM / yyyy').format(selectedDate.value!) : "dd / mm / aaaa",
                      style: TextStyle(color: selectedDate.value != null ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Horarios Disponibles (Cargan de Laravel)
            const Text("2. Horarios disponibles", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: controller.isFetchingSlots.value 
                ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
                : controller.availableSlots.isEmpty
                  ? Text(controller.slotMessage.value, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.center)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: controller.availableSlots.map((hora) {
                        bool isSelected = selectedSlot.value == hora;
                        return ChoiceChip(
                          label: Text(hora, style: TextStyle(color: isSelected ? Colors.white : MiTema.azulOscuro, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: MiTema.azulOscuro,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: MiTema.azulOscuro)),
                          onSelected: (bool selected) {
                            if (selected) selectedSlot.value = hora;
                          },
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 20),

            // 3. Motivo
            const Text("Motivo del cambio", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: motivoCtrl,
              decoration: InputDecoration(
                hintText: "Ej. Me surgió un contratiempo...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MiTema.azulOscuro, 
                  padding: const EdgeInsets.symmetric(vertical: 15), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: (selectedDate.value != null && selectedSlot.value != null)
                    ? () {
                        if (motivoCtrl.text.trim().isEmpty) {
                          Get.snackbar('Atención', 'Por favor, escribe un motivo.', backgroundColor: Colors.orange.shade100);
                          return;
                        }
                        String fechaFormat = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
                        controller.proponerCambio(cita['id'], fechaFormat, selectedSlot.value!, motivoCtrl.text.trim());
                      }
                    : null, // Desactiva el botón si no hay fecha y hora seleccionada
                child: const Text("Enviar Propuesta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )),
      ),
      isScrollControlled: true, // Permite que el bottom sheet crezca al abrir el teclado
    );
  }
}