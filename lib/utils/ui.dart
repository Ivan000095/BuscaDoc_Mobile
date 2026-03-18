import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:buscadoc_mobile/views/profile.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';

class UIUtils {
  static Widget divisor(double altura) {
    return Divider(height: altura, color: Colors.transparent);
  }

  static AppBar appbar({
    required String title,
    String? fotoUrl,
    VoidCallback? onProfileTap,
  }) {
    return AppBar(
      backgroundColor: MiTema.azulOscuro,
      elevation: 0,
      title: Image.asset('assets/logob.png', height: 40),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: onProfileTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: ClipOval(
                child: (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? Image.network(
                        fotoUrl,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 20, color: Colors.grey),
                      )
                    : const Icon(Icons.person, size: 20, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void showRoundedSnackBar(
    BuildContext context, 
    String message, 
    Color colorfondo, 
    Color colortexto,
    {IconData? icono}
  ) {
    
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icono != null) ...[
              Icon(icono, color: colortexto, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colortexto, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: colorfondo,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 6,
        animation: CurvedAnimation(
          parent: AnimationController(
            vsync: ScaffoldMessenger.of(context),
            duration: const Duration(milliseconds: 500),
          )..forward(),
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  static Drawer buildMenuLateral(
    BuildContext context, {
    required String userName,
    required String role,
    required String userEmail,
    String? fotoUrl,
  }) {
    String baseUrl = "http://127.0.0.1:8000/storage/";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        color: MiTema.blanco,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileOverview(context, userName, role, fotoUrl, baseUrl, userEmail),
            
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade200, thickness: 1),
            const SizedBox(height: 10),

            _buildMenuItem(
              icon: Icons.settings_sharp, 
              title: 'Configuración', 
              onTap: () {
                Navigator.pop(context);
              },
            ),
            
            const Spacer(),
            Divider(color: Colors.grey.shade200, thickness: 1),
            
            _buildMenuItem(
              icon: Icons.door_front_door_sharp, 
              title: 'Cerrar sesión', 
              iconColor: Colors.red.shade700,
              textColor: Colors.red.shade700,
              onTap: () async {
                await Usuario.logout(); 
if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const InicioSesion()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }


  static Widget _buildProfileOverview(BuildContext context, String userName, String role, String? fotoUrl, String baseUrl, String userEmail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      color: MiTema.azulOscuro.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  border: Border.all(color: MiTema.azulOscuro, width: 2),
                ),
                child: ClipOval(
                  child: (fotoUrl != null && fotoUrl.isNotEmpty)
                      ? Image.network(
                          fotoUrl.startsWith('http') ? fotoUrl : baseUrl + fotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: Colors.grey),
                        )
                      : const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 15),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: MiTema.azulOscuro
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12, 
                        color: Colors.grey, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarPerfil(
                    nombreActual: userName,
                    correoActual: userEmail,
                    fotoActual: fotoUrl ?? '', // Si es null, mandamos vacío
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: MiTema.azulOscuro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ver perfil detallado",
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuItem({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Icon(icon, color: iconColor ?? MiTema.azulOscuro, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
