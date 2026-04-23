import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:buscadoc_mobile/providers/alerta_provider.dart';
import 'package:buscadoc_mobile/model/alerta.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/theme/tema.dart';

class AlertaScreen extends StatefulWidget {
  const AlertaScreen({super.key});

  @override
  State<AlertaScreen> createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    _token = await Usuario.obtenerToken();
    
    if (_token != null && mounted) {
      final provider = Provider.of<AlertaProvider>(context, listen: false);
      
      await provider.refreshAlertas(_token!);
      
      if (provider.unreadCount > 0) {
        await provider.marcarTodasComoLeidas(_token!);
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertaProv = Provider.of<AlertaProvider>(context);

    return Scaffold(
      // 1. Fondo ligeramente gris para que las tarjetas blancas resalten
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Notificaciones", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: MiTema.azulOscuro,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            color: MiTema.azulOscuro,
            onRefresh: () async {
              if (_token != null) {
                await alertaProv.refreshAlertas(_token!);
              }
            },
            child: alertaProv.alertas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16), // Espaciado alrededor de la lista
                    itemCount: alertaProv.alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertaProv.alertas[index];
                      return _buildAlertaItem(alerta, alertaProv, _token!);
                    },
                  ),
          ),
    );
  }

  Widget _buildAlertaItem(Alerta alerta, AlertaProvider provider, String token) {
    // 2. Variable para saber si resaltar la tarjeta
    bool isUnread = !alerta.leido;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bordes bien redondeados
        boxShadow: [
          // Sombra solo si NO está leída para darle profundidad
          if (isUnread)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
        border: Border.all(
          // Borde azul sutil si es nueva, borde gris claro si ya se leyó
          color: isUnread ? Colors.blue.withOpacity(0.3) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. Icono Moderno (Contenedor cuadrado con bordes redondeados)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getIconColor(alerta.tipo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(alerta.tipo),
              color: _getIconColor(alerta.tipo),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 4. Contenido de texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alerta.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: isUnread ? MiTema.azulOscuro : Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 5. El puntito azul de "No Leído"
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alerta.mensaje,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.3, // Interlineado para mejor lectura
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // Formato de fecha un poco más limpio
                  DateFormat('dd MMM yyyy • hh:mm a').format(alerta.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String tipo) {
    return tipo == 'mensaje' ? Icons.chat_bubble_outline_rounded : Icons.calendar_today_rounded;
  }

  Color _getIconColor(String tipo) {
    return tipo == 'mensaje' ? Colors.blue : Colors.teal; // Teal se ve más moderno que el verde puro
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        // Icono de vacío modernizado
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            "Todo al día",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "No tienes notificaciones nuevas por ahora.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
      ],
    );
  }
}