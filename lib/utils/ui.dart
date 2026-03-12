import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF00213D), // MiTema.azulOscuro
      elevation: 0,
      title: Image.asset('assets/logob.png', height: 40),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: onProfileTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                  ? NetworkImage(fotoUrl)
                  : null,
              child: (fotoUrl == null || fotoUrl.isEmpty)
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
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
}
