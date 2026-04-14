import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class FarmaciaController extends GetxController {
  var farmacias = <Farmacia>[].obs;
  var cargando = false.obs;
  var mensajeError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cargarFarmacias();
  }

  Future<void> cargarFarmacias() async {
    cargando.value = true;
    mensajeError.value = '';

    try {
      final response = await http.get(
        Uri.parse('${Globals.webUrl}/api/farmacias'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> listaData = data['data'];
          farmacias.assignAll(
            listaData.map((jsonItem) => Farmacia.fromJson(jsonItem)).toList()
          );
        } else {
          mensajeError.value = data['message'] ?? 'Error desconocido';
        }
      } else {
        mensajeError.value = 'Error HTTP ${response.statusCode}';
      }
    } catch (e) {
      mensajeError.value = 'Error de red: $e';
    } finally {
      cargando.value = false;
    }
  }
}