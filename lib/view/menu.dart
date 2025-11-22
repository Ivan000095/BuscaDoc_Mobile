import 'package:flutter/material.dart';
import 'package:xd/theme/tema.dart';

Drawer menu(BuildContext context) {
  return Drawer(
    backgroundColor: MiTema.azulMarino,
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
      leading: Icon(Icons.handshake, color: MiTema.azulhielo,),
      title: Text(
        'Hola, Doctor',
        style: 
          TextStyle(fontStyle: FontStyle.italic, color: MiTema.azulhielo), 
        ),
      subtitle: Text('Bienvenido a la casa de los sustos', style: TextStyle(color: MiTema.azulhielo),),
    )
  );
}

Widget _cita(BuildContext context) {
  return _opcion(
    Icons.calendar_month, 
    'Citas',
    () {
      SnackBar mensaje = SnackBar(
        content: Text(
          'Citas',
          style: TextStyle(
            color: MiTema.azulhielo
          ),
        )
      );
      ScaffoldMessenger.of(context).showSnackBar(mensaje);
    }
  );
}

Widget _otro(BuildContext context) {
  return _opcion(
    Icons.device_hub_outlined, 
    'Otro',
    () {SnackBar mensaje = SnackBar(content: Text(
      'Pendejo', style: TextStyle(
        color: MiTema.azulhielo
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
    color: MiTema.verdepetroleo,
  );
}

Widget _opcion(IconData icono, String texto, Function() accion) {
   return MenuItemButton(
    leadingIcon: Icon(icono, color: MiTema.azulhielo,),
    onPressed: accion,
    child: Text(
      texto,
      style: TextStyle(
        color: MiTema.azulhielo
      ),
    ),
  );
}