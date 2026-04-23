import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/model/alerta.dart';
import 'package:buscadoc_mobile/services/alerta_service.dart';

class AlertaProvider with ChangeNotifier {
  List<Alerta> _alertas = [];
  int _unreadCount = 0;
  final AlertaService _service = AlertaService();

  List<Alerta> get alertas => _alertas;
  int get unreadCount => _unreadCount;

  Future<void> refreshAlertas(String token) async {
    _alertas = await _service.getAlertas(token);
    _unreadCount = _alertas.where((a) => !a.leido).length;
    notifyListeners();
  }

  Future<void> leerAlerta(String token, Alerta alerta) async {
    if (!alerta.leido) {
      await _service.marcarLeida(token, alerta.id);
      await refreshAlertas(token); // Refrescamos la lista y el contador
    }
  }

  Future<void> marcarTodasComoLeidas(String token) async {
    await _service.marcarTodasLeidas(token);
    
    _unreadCount = 0;
    notifyListeners();
  }
}