import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/model/contactos.dart';
import 'package:buscadoc_mobile/model/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:magicoon_icons/icon_data/magicoon_filled_icons.dart';

class VistaChatView extends StatefulWidget {
  final ContactoChat contacto;

  const VistaChatView({super.key, required this.contacto});

  @override
  State<VistaChatView> createState() => _VistaChatViewState();
}

class _VistaChatViewState extends State<VistaChatView> {
  final Color bgCanvas = const Color(0xFFF0F4F8); 
  final Color bgSurface = const Color(0xFFFBFCFD); 
  final Color brandNavy = const Color(0xFF112A46); 
  
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
      chatId = id1 < id2 ? "${id1}_${id2}" : "${id2}_${id1}";
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
        backgroundColor: bgSurface,
        elevation: 1,
        shadowColor: brandNavy.withOpacity(0.2),
        iconTheme: IconThemeData(color: brandNavy),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.contacto.fotoUrl),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contacto.nombre,
                    style: TextStyle(color: brandNavy, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.contacto.especialidad.isNotEmpty ? widget.contacto.especialidad : 'Paciente',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      body: configurando 
        ? Center(child: CircularProgressIndicator(color: brandNavy))
        : Column(
            children: [
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref('mensajes')
                      .orderByChild('chat_id')
                      .equalTo(chatId)
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error de conexión'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: brandNavy));
                    }

                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return _buildEmptyState();
                    }

                    Map<dynamic, dynamic> mapaMensajes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Mensaje> mensajes = mapaMensajes.values.map((jsonInfo) {
                      return Mensaje.fromJson(Map<String, dynamic>.from(jsonInfo), miId);
                    }).toList();

                    mensajes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(15),
                      itemCount: mensajes.length,
                      itemBuilder: (context, index) {
                        return _buildBurbuja(mensajes[index]);
                      },
                    );
                  }
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: bgSurface,
                  border: Border(top: BorderSide(color: brandNavy.withOpacity(0.1))),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgCanvas,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: brandNavy.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: brandNavy,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(MagicoonFilled.send, color: Colors.white),
                          onPressed: _enviarMensaje,
                        ),
                      )
                    ],
                  ),
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isMine ? brandNavy : bgSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isMine ? 20 : 5),
            bottomRight: Radius.circular(msg.isMine ? 5 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: brandNavy.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          msg.contenido,
          style: TextStyle(
            color: msg.isMine ? Colors.white : brandNavy,
            fontSize: 15,
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
          Icon(Icons.chat_bubble_outline, size: 60, color: brandNavy.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Aún no hay mensajes. ¡Di hola!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}