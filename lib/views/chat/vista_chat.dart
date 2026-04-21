import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Asegúrate de tener GetX importado para la navegación si lo usas
import 'package:buscadoc_mobile/model/contactos.dart';
import 'package:buscadoc_mobile/model/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/theme/tema.dart'; // Tu tema con MiTema.azulOscuro

class VistaChatView extends StatefulWidget {
  final ContactoChat contacto;

  const VistaChatView({super.key, required this.contacto});

  @override
  State<VistaChatView> createState() => _VistaChatViewState();
}

class _VistaChatViewState extends State<VistaChatView> {
  final Color bgCanvas = const Color(0xFFF5F7F9); // Fondo grisáceo muy claro
  final TextEditingController _msgController = TextEditingController();

  String miToken = '';
  String miId = '';
  String chatId = '';
  bool configurando = true;

  @override
  void initState() {
    super.initState();
    _prepararChat();
  }

  Future<void> _prepararChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idLocal = prefs.getString('id') ?? '';
    
    int id1 = int.tryParse(idLocal) ?? 0;
    int id2 = int.tryParse(widget.contacto.id) ?? 0;
    
    setState(() {
      miId = idLocal;
      miToken = prefs.getString('token') ?? '';
      chatId = id1 < id2 ? "${id1}_$id2" : "${id2}_$id1";
      configurando = false;
    });
  }

  void _enviarMensaje() async {
    String texto = _msgController.text.trim();
    if (texto.isEmpty) return;
    _msgController.clear();
    await Mensaje.enviarMensaje(miToken, widget.contacto.id, texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: MiTema.azulOscuro.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.contacto.fotoUrl),
                radius: 20,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contacto.nombre,
                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.contacto.especialidad.isNotEmpty ? widget.contacto.especialidad : 'Paciente',
                    style: TextStyle(color: MiTema.azulOscuro, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(MagicoonFilled.phone, color: MiTema.azulOscuro, size: 20),
            onPressed: () {
              // Simulación de botón de llamada (puedes agregar funcionalidad luego)
              Get.snackbar("Llamada", "Función de llamada próximamente", backgroundColor: Colors.white);
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
      
      body: configurando 
        ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
        : Column(
            children: [
              // ÁREA DE MENSAJES
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref('mensajes')
                      .orderByChild('chat_id')
                      .equalTo(chatId)
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error de conexión', style: TextStyle(color: Colors.grey)));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: MiTema.azulOscuro));
                    }

                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return _buildEmptyState();
                    }

                    Map<dynamic, dynamic> mapaMensajes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Mensaje> mensajes = mapaMensajes.values.map((jsonInfo) {
                      return Mensaje.fromJson(Map<String, dynamic>.from(jsonInfo), miId);
                    }).toList();

                    // Ordenar por fecha (el más reciente abajo)
                    mensajes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return ListView.builder(
                      reverse: true, // Empieza desde abajo
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      itemCount: mensajes.length,
                      itemBuilder: (context, index) {
                        return _buildBurbuja(mensajes[index]);
                      },
                    );
                  }
                ),
              ),

              // ÁREA DE INPUT DE TEXTO
              Container(
                padding: EdgeInsets.only(
                  left: 15, right: 15, top: 10,
                  // Agregamos padding inferior seguro para dispositivos sin botones (iPhone/Android modernos)
                  bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 10 : 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, -5))
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgCanvas,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _msgController,
                          minLines: 1,
                          maxLines: 4, // Crece hasta 4 líneas si el texto es largo
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      margin: const EdgeInsets.only(bottom: 2), // Alineación visual con el TextField
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: MiTema.azulOscuro.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(MagicoonFilled.sendRight, color: Colors.white, size: 20),
                        onPressed: _enviarMensaje,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
    );
  }

  Widget _buildBurbuja(Mensaje msg) {
    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), // Máximo 75% del ancho
        decoration: BoxDecoration(
          // GRADIENTE si es mi mensaje, BLANCO si es del otro
          gradient: msg.isMine 
            ? LinearGradient(
                colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) 
            : null,
          color: msg.isMine ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isMine ? 20 : 5),
            bottomRight: Radius.circular(msg.isMine ? 5 : 20),
          ),
          boxShadow: [
            if (!msg.isMine) // Solo sombra ligera para los mensajes recibidos
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Text(
          msg.contenido,
          style: TextStyle(
            color: msg.isMine ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
            ),
            child: Icon(MagicoonFilled.chat, size: 50, color: MiTema.azulOscuro.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Inicia la conversación!', 
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            'Envía un mensaje para comenzar\nel chat seguro.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)
          ),
        ],
      ),
    );
  }
}