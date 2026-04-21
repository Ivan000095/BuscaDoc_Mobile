import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/model/contactos.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/views/chat/vista_chat.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/theme/tema.dart';

class ListaContactosView extends StatefulWidget {
  const ListaContactosView({super.key});

  @override
  State<ListaContactosView> createState() => _ListaContactosViewState();
}

class _ListaContactosViewState extends State<ListaContactosView> {
  final Color bgCanvas = const Color(0xFFF5F7F9);
  final Color textMuted = const Color(0xFF64748B);

  // NUESTRAS 3 VARIABLES ESTRELLA PARA LA BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  List<ContactoChat> contactosOriginales = [];
  List<ContactoChat> contactosFiltrados = [];
  
  bool isLoading = true;
  String mensajeError = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    
    // Esto hace que el icono de "X" se actualice dinámicamente al escribir
    _searchController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        // AMBAS listas se llenan al inicio
        contactosOriginales = List.from(datos);
        contactosFiltrados = List.from(datos);
        isLoading = false;
      });
    }
  }

  void _filtrarContactos(String query) {
    if (query.isEmpty) {
      setState(() {
        contactosFiltrados = List.from(contactosOriginales);
      });
    } else {
      setState(() {
        contactosFiltrados = contactosOriginales.where((contacto) {
          final nombreLower = contacto.nombre.toLowerCase();
          final especialidadLower = contacto.especialidad.toLowerCase();
          final busquedaLower = query.toLowerCase();
          
          return nombreLower.contains(busquedaLower) || especialidadLower.contains(busquedaLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MiTema.azulOscuro.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(MagicoonFilled.chatDots, color: MiTema.azulOscuro, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mensajes',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // BARRA DE BÚSQUEDA
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 5),
            child: Container(
              decoration: BoxDecoration(
                color: bgCanvas,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filtrarContactos,
                decoration: InputDecoration(
                  hintText: 'Buscar conversación...',
                  hintStyle: TextStyle(color: textMuted.withOpacity(0.7), fontSize: 15),
                  prefixIcon: Icon(MagicoonRegular.search, color: textMuted, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey.shade400, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarContactos('');
                            FocusScope.of(context).unfocus(); // Cierra el teclado
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // LISTA DE CONTACTOS
          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
              : contactosFiltrados.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 15, bottom: 40),
                  itemCount: contactosFiltrados.length, 
                  itemBuilder: (context, index) {
                    return _buildContactPill(contactosFiltrados[index]); 
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
            ),
            child: Icon(MagicoonRegular.inboxEmpty, size: 60, color: MiTema.azulOscuro.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isNotEmpty ? 'No hay coincidencias' : 'No tienes conversaciones',
            style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _searchController.text.isNotEmpty 
                ? 'Intenta buscar con otro nombre.'
                : 'Tus chats con doctores y pacientes\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPill(ContactoChat contacto) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VistaChatView(contacto: contacto)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade100, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: bgCanvas,
                          backgroundImage: NetworkImage(contacto.fotoUrl),
                        ),
                      ),
                      if (contacto.enLinea)
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
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
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              contacto.rol == 'doctor' ? MagicoonFilled.stethoscope : MagicoonFilled.user,
                              size: 12, color: contacto.rol == 'doctor' ? MiTema.azulOscuro : textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                contacto.rol == 'doctor' ? contacto.especialidad : 'Paciente',
                                style: TextStyle(
                                  color: contacto.rol == 'doctor' ? MiTema.azulOscuro : textMuted, 
                                  fontSize: 13,
                                  fontWeight: contacto.rol == 'doctor' ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (contacto.mensajesSinLeer > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: MiTema.azulOscuro.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                      child: Text(
                        contacto.mensajesSinLeer > 9 ? '+9' : contacto.mensajesSinLeer.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}