import 'package:buscadoc_mobile/paciente/agendacita.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:get/get.dart';

Drawer menu(BuildContext context) {
  return Drawer(
    backgroundColor: MiTema.azulOscuro,
    child: Column(
      children: [
        _encabezado(),
        _cita(context),
        _otro(context),
        _divisor(),
        _salir(context),
      ]
    )
  );
}

Widget _encabezado() {
  return DrawerHeader(
    child: ListTile(
      leading: Icon(Icons.handshake, color: MiTema.blanco,),
      title: Text(
        'Hola, Doctor',
        style: 
          TextStyle(fontStyle: FontStyle.italic, color: MiTema.blanco), 
        ),
      subtitle: Text('Bienvenido a la casa de los sustos', style: TextStyle(color: MiTema.blanco),),
    )
  );
}

Widget _cita(BuildContext context) {
  return _opcion(
    Icons.calendar_month, 
    'Citas',
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendarCita(), // Necesitas pasarle un objeto doctor
        ),
      );
     /*  SnackBar mensaje = SnackBar(
        content: Text(
          'Citas',
          style: TextStyle(
            color: MiTema.negro
          ),
        )
      ); */
      /* ScaffoldMessenger.of(context).showSnackBar(mensaje); */
    }
  );
}

Widget _otro(BuildContext context) {
  return _opcion(
    Icons.device_hub_outlined, 
    'Otro',
    () {SnackBar mensaje = SnackBar(content: Text(
      'Pendejo', style: TextStyle(
        color: MiTema.blanco
          ),
        )
      );
    ScaffoldMessenger.of(context).showSnackBar(mensaje);
    }
  );
}

Widget _salir(BuildContext context) {
   return _opcion(Icons.door_back_door_outlined, 'Salir',() {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    } );
}

Widget _divisor() {
  return Divider(
    height: 20,
    color: MiTema.blanco,
  );
}

Widget _opcion(IconData icono, String texto, Function() accion) {
   return MenuItemButton(
    leadingIcon: Icon(icono, color: MiTema.blanco,),
    onPressed: accion,
    child: Text(
      texto,
      style: TextStyle(
        color: MiTema.blanco
      ),
    ),
  );
}