import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/providers/expediente_provider.dart';
import 'package:buscadoc_mobile/model/expediente.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class ExpedientesController extends GetxController {
  var isLoading = true.obs;
  var expedientes = <Expediente>[].obs;

  // Campos para el formulario
  final nombreCtrl = TextEditingController();
  final fechaNacimiento = Rxn<DateTime>();
  var genero = 'masculino'.obs;
  final parentescoCtrl = TextEditingController();
  var sangreVal = RxnString();
  final alergiasCtrl = TextEditingController();
  final padecimientosCtrl = TextEditingController();
  final habitosCtrl = TextEditingController();
  String? fotoPerfilUsuario; 

  @override
  void onInit() {
    super.onInit();
    fetchExpedientes();
    cargarDatosPersonales();
  }

  Future<void> fetchExpedientes() async {
    isLoading(true);
    var response = await ExpedientesProvider.getExpedientes();
    if (response['success'] == true) {
      var list = response['data'] as List;
      expedientes.assignAll(list.map((e) => Expediente.fromJson(e)).toList());
    }
    isLoading(false);
  }

  Future<void> guardarExpediente() async {
    if (nombreCtrl.text.isEmpty || fechaNacimiento.value == null || parentescoCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Nombre, fecha y parentesco son obligatorios', backgroundColor: Colors.red.shade100);
      return;
    }

    isLoading(true);
    Map<String, dynamic> data = {
      'nombre_completo': nombreCtrl.text,
      'fecha_nacimiento': fechaNacimiento.value!.toIso8601String().split('T')[0],
      'genero': genero.value,
      'parentesco': parentescoCtrl.text,
      'tipo_sangre': sangreVal.value ?? '',
      'alergias': alergiasCtrl.text,
      'padecimientos_cronicos': padecimientosCtrl.text,
      'habitos_salud': habitosCtrl.text,
    };

    var res = await ExpedientesProvider.crearExpediente(data);
    if (res['success'] == true) {
      Get.back(); // Volver a la lista
      fetchExpedientes(); // Recargar lista
      Get.snackbar('Éxito', 'Expediente guardado');
    }
    isLoading(false);
  }

  Future<void> cargarDatosPersonales() async {
    try {
      final fotoPerfilUsuario = RxnString();
      Map<String, String> userData = await Usuario.obtenerDatosSesion(); 
      
      if (userData['foto'] != null && userData['foto']!.isNotEmpty) {
        fotoPerfilUsuario.value = userData['foto'];
      }
    } catch (e) {
      print("No se pudo cargar la foto de perfil: $e");
    }
  }
}