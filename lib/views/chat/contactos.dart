import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/model/contactos.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/views/chat/vista_chat.dart';

class ListaContactosView extends StatefulWidget {
  const ListaContactosView({super.key});

  @override
  State<ListaContactosView> createState() => _ListaContactosViewState();
}

class _ListaContactosViewState extends State<ListaContactosView> {
  final Color bgCanvas = const Color(0xFFF0F4F8);
  final Color bgSurface = const Color(0xFFFBFCFD);
  final Color brandNavy = const Color(0xFF112A46);
  final Color textMuted = const Color(0xFF64748B);

  List<ContactoChat> contactos = [];
  bool isLoading = true;
  String mensajeError = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    String? miToken = await Usuario.obtenerToken();

    if (miToken == null || miToken.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
          mensajeError = 'Sesión no válida.';
        });
      }
      return;
    }

    final datos = await ContactoChat.obtenerContactos(miToken);

    if (mounted) {
      setState(() {
        contactos = datos;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: bgCanvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: brandNavy, size: 28),
            const SizedBox(width: 12),
            Text(
              'Mensajes',
              style: TextStyle(
                color: brandNavy,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: bgSurface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: brandNavy.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: brandNavy.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar conversación...',
                  hintStyle: TextStyle(color: textMuted.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator(color: brandNavy))
              : contactos.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: contactos.length,
                  itemBuilder: (context, index) {
                    return _buildContactPill(contactos[index]);
                  },
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes conversaciones aún',
            style: TextStyle(color: textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPill(ContactoChat contacto) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: brandNavy.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: brandNavy.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VistaChatView(contacto: contacto),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: bgCanvas, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(contacto.fotoUrl),
                      ),
                    ),
                    if (contacto.enLinea)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: bgSurface, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        contacto.nombre,
                        style: TextStyle(
                          color: brandNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            contacto.rol == 'doctor'
                                ? Icons.medical_services_outlined
                                : Icons.person_outline,
                            size: 14,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contacto.rol == 'doctor'
                                  ? contacto.especialidad
                                  : 'Paciente',
                              style: TextStyle(color: textMuted, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (contacto.mensajesSinLeer > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brandNavy,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      contacto.mensajesSinLeer.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: textMuted.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
