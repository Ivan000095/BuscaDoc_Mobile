import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/model/citas_provider.dart';

class CitasController extends GetxController {
  // Variables reactivas
  var isLoading = true.obs;
  var isActionLoading = false.obs;
  var citasList = [].obs;
  var availableSlots = <String>[].obs;
  var isFetchingSlots = false.obs;
  var slotMessage = "Elige una fecha para ver horarios disponibles".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCitas();
  }

  Future<void> fetchCitas() async {
    isLoading(true);
    var response = await CitasProvider.getCitas();
    
    if (response['success'] == true) {
      citasList.assignAll(response['data']);
    } else {
      Get.snackbar('Error', response['message'] ?? 'No se pudieron cargar las citas', 
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
    }
    isLoading(false);
  }

  Future<void> cancelarCita(int citaId) async {
    isActionLoading(true);
    var response = await CitasProvider.updateStatus(citaId, 'cancelada');
    _handleResponse(response, onSuccess: () => fetchCitas());
  }

  Future<void> eliminarCita(int citaId) async {
    isActionLoading(true);
    var response = await CitasProvider.eliminarCita(citaId);
    _handleResponse(response, onSuccess: () {
      citasList.removeWhere((cita) => cita['id'] == citaId);
    });
  }

  Future<void> responderPropuesta(int citaId, String accion, {String? motivo}) async {
    isActionLoading(true);
    var response = await CitasProvider.responderCambio(citaId, accion, motivo: motivo);
    
    if (accion == 'rechazar') Get.back();
    
    _handleResponse(response, onSuccess: () => fetchCitas());
  }

  void _handleResponse(Map<String, dynamic> response, {required Function onSuccess}) {
    isActionLoading(false);
    if (response['success'] == true) {
      Get.snackbar('Éxito', response['message'] ?? 'Acción realizada', 
          backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900, snackPosition: SnackPosition.BOTTOM);
      onSuccess();
    } else {
      Get.snackbar('Atención', response['message'] ?? 'Ocurrió un error', 
          backgroundColor: Colors.orange.shade100, colorText: Colors.orange.shade900, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchDisponibilidad(int doctorId, String fecha) async {
    isFetchingSlots(true);
    availableSlots.clear();
    
    var response = await CitasProvider.getDisponibilidad(doctorId, fecha);
    
    if (response['slots'] != null && (response['slots'] as List).isNotEmpty) {
      availableSlots.assignAll(List<String>.from(response['slots']));
      slotMessage('');
    } else {
      slotMessage(response['mensaje'] ?? 'Sin horarios disponibles para este día.');
    }
    isFetchingSlots(false);
  }

  Future<void> proponerCambio(int citaId, String fecha, String hora, String motivo) async {
    isActionLoading(true);
    var response = await CitasProvider.solicitarCambio(citaId, fecha, hora, motivo);
    
    Get.back();
    _handleResponse(response, onSuccess: () => fetchCitas());
  }
}