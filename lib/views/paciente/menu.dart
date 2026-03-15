import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'perfil.dart';
import 'package:buscadoc_mobile/main.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        color: MiTema.blanco,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            
            const SizedBox(height: 20),

            _buildMenuItem(
              icon: Icons.person_sharp, 
              title: 'Perfil', 
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Perfil()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_sharp, 
              title: 'Configuración', 
              onTap: () => Navigator.pop(context),
            ),
            
            _buildMenuItem(
              icon: Icons.door_front_door_sharp, 
              title: 'Cerrar sesión', 
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logon.png',
            width: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text("BUSCA DOC", style: TextStyle(fontWeight: FontWeight.bold));
            },
          ),
          const Text(
            'Maria P.',
            style: TextStyle(
              fontSize: 14, 
              color: Colors.grey, 
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Icon(icon, color: MiTema.azulOscuro, size: 30),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}