import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/model/expediente.dart';
import 'package:buscadoc_mobile/providers/expediente_provider.dart';

class ExpedienteDetalleController extends GetxController {
  final int expedienteId;
  ExpedienteDetalleController({required this.expedienteId});

  var isLoading = true.obs;
  var isSaving = false.obs;
  
  var expediente = Rxn<Expediente>();
  var notasMedicas = [].obs;

  // Controladores para el formulario de edición
  final nombreCtrl = TextEditingController();
  final fechaNacimiento = Rxn<DateTime>();
  var genero = 'masculino'.obs;
  final parentescoCtrl = TextEditingController();
  var sangreVal = RxnString();
  final alergiasCtrl = TextEditingController();
  final padecimientosCtrl = TextEditingController();
  final habitosCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDetalle();
  }

  Future<void> fetchDetalle() async {
    isLoading(true);
    var res = await ExpedientesProvider.getExpedienteDetalle(expedienteId);
    if (res['success'] == true) {
      expediente.value = Expediente.fromJson(res['data']);
      notasMedicas.assignAll(res['data']['notas'] ?? []);
      _prellenarFormulario(expediente.value!);
    }
    isLoading(false);
  }

  void _prellenarFormulario(Expediente exp) {
    nombreCtrl.text = exp.nombreCompleto;
    fechaNacimiento.value = DateTime.tryParse(exp.fechaNacimiento);
    genero.value = exp.genero;
    parentescoCtrl.text = exp.parentesco;
    List<String> tiposValidos = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    sangreVal.value = tiposValidos.contains(exp.tipoSangre) ? exp.tipoSangre : null;
    alergiasCtrl.text = exp.alergias ?? '';
    padecimientosCtrl.text = exp.padecimientos ?? '';
    habitosCtrl.text = exp.habitos ?? '';
  }

  Future<void> guardarEdicion() async {
    if (nombreCtrl.text.isEmpty || fechaNacimiento.value == null || parentescoCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Nombre, fecha y parentesco son obligatorios', backgroundColor: Colors.red.shade100);
      return;
    }

    isSaving(true);
    Map<String, dynamic> data = {
      'nombre_completo': nombreCtrl.text.trim(),
      'fecha_nacimiento': fechaNacimiento.value!.toIso8601String().split('T')[0],
      'genero': genero.value,
      'parentesco': parentescoCtrl.text.trim(),
      'tipo_sangre': sangreVal.value ?? '',
      'alergias': alergiasCtrl.text.trim(),
      'padecimientos_cronicos': padecimientosCtrl.text.trim(),
      'habitos_salud': habitosCtrl.text.trim(),
    };

    var res = await ExpedientesProvider.actualizarExpediente(expedienteId, data);
    
    if (res['success'] == true) {
      Get.back(); // Cerrar el bottom sheet
      Get.snackbar('Éxito', 'Expediente actualizado', backgroundColor: Colors.green.shade100);
      fetchDetalle(); // Recargar los datos visuales
    } else {
      Get.snackbar('Error', res['message'] ?? 'Hubo un problema al guardar', backgroundColor: Colors.red.shade100);
    }
    isSaving(false);
  }
}