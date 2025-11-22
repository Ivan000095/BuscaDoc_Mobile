import 'package:flutter/material.dart';
import 'package:xd/model/entrega.dart';
import 'package:xd/theme/tema.dart';
import 'package:xd/utils/formatos.dart';

class VistaEntrega extends StatefulWidget {
  const VistaEntrega({super.key, required this.title});
  final String title;

  @override
  VistaEntregaState createState() => VistaEntregaState();
}

class VistaEntregaState extends State<VistaEntrega> {
  late Entrega entrega;

  @override
  Widget build(BuildContext context) {
    final Entrega entrega =
        ModalRoute.of(context)!.settings.arguments as Entrega;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('entrega #${entrega.numero}'),
          backgroundColor: MiTema.azulMarino,
        ),
        body: Column(
          children: [
            ListTile(
              leading: Icon(Icons.add_a_photo_outlined),
              title: Text(Formatos.fecha(entrega.fecha)),
              subtitle: Text('putos'),
              tileColor: MiTema.verdepetroleo,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: SizedBox(
                width: 285,
                child: TextField(
                  controller: null,
                  decoration: InputDecoration(
                    hintText: 'Subir archivo',
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: MiTema.azulavanda),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: MiTema.negro, width: 2),
                    ),
                  ),
                  readOnly: true,
                ),
              ),
              title: Icon(Icons.picture_as_pdf_rounded, color: MiTema.azulMarino,),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _formEntrega() {
    return Column(children: [_infoentrega()]);
  }

  Widget _infoentrega() {
    return ListTile(
      leading: Icon(Icons.add_a_photo_outlined),
      title: Text(Formatos.fecha(entrega.fecha)),
      subtitle: Text('putos'),
      tileColor: MiTema.verdepetroleo,
    );
  }
}
