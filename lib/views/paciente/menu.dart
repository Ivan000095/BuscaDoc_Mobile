import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'perfil.dart';
import 'package:buscadoc_mobile/main.dart';

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
            
            // OPCIÓN ACTUALIZADA: Cerrar Sesión
            _buildMenuItem(
              icon: Icons.door_front_door_sharp, 
              title: 'Cerrar sesión', 
              onTap: () {
                // Navigator.pushAndRemoveUntil elimina todas las rutas anteriores
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()), // MyApp es tu clase en main.dart
                  (Route<dynamic> route) => false, // Esto hace que no se pueda regresar
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ... (Tus métodos _buildHeader y _buildMenuItem se mantienen iguales)
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