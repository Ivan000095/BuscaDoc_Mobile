import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buscadoc_mobile/providers/agendar_provider.dart';
import 'package:buscadoc_mobile/model/citas_provider.dart';

class AgendarController extends GetxController {
  final int doctorId;
  AgendarController({required this.doctorId});

  // Variables reactivas para el formulario
  var isLoading = false.obs;
  var expedientes = [].obs;
  var availableSlots = <String>[].obs;
  
  var selectedDate = Rxn<DateTime>();
  var selectedSlot = RxnString();
  var selectedExpediente = RxnString(); // Guardará el ID del expediente
  final motivoCtrl = TextEditingController();

  var slotMessage = "Selecciona una fecha primero".obs;
  var isFetchingSlots = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargarExpedientes();
  }

  Future<void> cargarExpedientes() async {
    var res = await AgendarProvider.getExpedientes();
    if (res['success'] == true) {
      expedientes.assignAll(res['data']);
      if (expedientes.isNotEmpty) {
        selectedExpediente.value = expedientes[0]['id'].toString(); // Seleccionar el primero por defecto
      }
    }
  }

  Future<void> buscarHorarios(DateTime fecha) async {
    selectedDate.value = fecha;
    selectedSlot.value = null;
    isFetchingSlots(true);
    availableSlots.clear();

    String fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    var res = await CitasProvider.getDisponibilidad(doctorId, fechaStr);

    if (res['slots'] != null && (res['slots'] as List).isNotEmpty) {
      availableSlots.assignAll(List<String>.from(res['slots']));
      slotMessage('');
    } else {
      slotMessage(res['mensaje'] ?? 'Sin horarios disponibles.');
    }
    isFetchingSlots(false);
  }

  Future<void> confirmarCita() async {
    if (selectedDate.value == null || selectedSlot.value == null || selectedExpediente.value == null || motivoCtrl.text.trim().isEmpty) {
      Get.snackbar('Atención', 'Por favor completa todos los campos', backgroundColor: Colors.orange.shade100);
      return;
    }

    isLoading(true);
    
    Map<String, dynamic> datosCita = {
      'fecha': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      'hora_inicio': selectedSlot.value,
      'expediente_id': selectedExpediente.value,
      'motivo_consulta': motivoCtrl.text.trim(),
    };

    var response = await AgendarProvider.agendarCita(doctorId, datosCita);
    isLoading(false);

    if (response['success'] == true || response['message'] == 'Cita programada correctamente!!') {
      // 1. PRIMERO cerramos las dos pantallas (Agendar y Perfil del Doctor)
      Get.close(2); 

      // 2. DESPUÉS mostramos el mensaje de éxito (aparecerá en la pantalla base)
      Get.snackbar(
        '¡Éxito!', 
        'Cita agendada correctamente', 
        backgroundColor: Colors.green.shade100, 
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM, // Opcional: Abajo suele verse mejor
      );
    } else {
      Get.snackbar(
        'Error', 
        response['message'] ?? 'El horario ya fue ocupado', 
        backgroundColor: Colors.red.shade100, 
        colorText: Colors.red.shade900
      );
    }
  }
}