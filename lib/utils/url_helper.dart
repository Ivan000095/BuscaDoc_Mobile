import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class UrlHelper {
  static Future<void> openMaps(double lat, double lng) async {
    if (lat == 0 || lng == 0) {
      Get.snackbar(
        'Sin ubicación',
        'Esta farmacia no tiene coordenadas registradas.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar(
        'Error',
        'No se pudo abrir Google Maps. Verifica que esté instalado.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Sin teléfono',
        'No hay número registrado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final url = Uri.parse('tel:$phoneNumber');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'No se pudo realizar la llamada.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'No se pudo abrir el enlace.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}