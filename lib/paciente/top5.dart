import 'package:buscadoc_mobile/paciente/doctor.dart';
import 'package:buscadoc_mobile/paciente/farmacia.dart';
import 'package:buscadoc_mobile/paciente/menu.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';


class Top5 extends StatefulWidget {
  const Top5({Key? key}) : super(key: key);

  @override
  State<Top5> createState() => _Top5State();
}

class _Top5State extends State<Top5> {
  // El índice 0 corresponde al Home (Top 5)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // 1. SE AGREGA EL DRAWER AL SCAFFOLD
      drawer: const MenuLateral(),
      appBar: AppBar(
        backgroundColor: MiTema.azulOscuro,
        elevation: 0,
        // 2. BUILDER PARA ABRIR EL DRAWER CORRECTAMENTE
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Top 5 mejores',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity, height: 10),
                const Text(
                  'Top 5 mejores',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'Especialistas mejor calificados',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                
                // --- TARJETAS CON NAVEGACIÓN ---
                _buildModernCard('Dr. Juan Carlos P. Gomez', 'Cardiólogo', 'assets/doctor1.jpg', true, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Doctor()));
                }),
                const SizedBox(height: 16),
                _buildModernCard('Farmacia Guadalajara', 'Abierto 24h', 'assets/farmaciag.avif', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Farmacia()));
                }),
                const SizedBox(height: 16),
                _buildModernCard('Dra. María López', 'Pediatra', 'assets/doctor1.jpg', true, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Doctor()));
                }),
                const SizedBox(height: 16),
                _buildModernCard('Hospital Central', 'Urgencias', 'assets/doctor.png', false, () {
                  // Acción para Hospital
                }),
              ],
            ),
          ),

          // --- BARRA DE NAVEGACIÓN ESTILO DOCTOR ---
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  // MÉTODO PARA LA BARRA DE NAVEGACIÓN (IGUAL A DOCTOR/FARMACIA)
  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 30,
      left: 50,
      right: 50,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: MiTema.azulOscuro,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home (Seleccionado en esta pantalla)
            IconButton(
              icon: Icon(Icons.home_rounded, 
                  color: _selectedIndex == 0 ? Colors.cyanAccent : Colors.white, 
                  size: _selectedIndex == 0 ? 32 : 28),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            // Salud (Doctor)
            IconButton(
              icon: Icon(Icons.health_and_safety_rounded, 
                  color: Colors.white, 
                  size: _selectedIndex == 1 ? 32 : 28),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Doctor()));
              },
            ),
            // Medicina (Farmacia)
            IconButton(
              icon: Icon(Icons.medication_rounded, 
                  color: Colors.white, 
                  size: _selectedIndex == 2 ? 32 : 28),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Farmacia()));
              },
            ),
            // Búsqueda
            IconButton(
              icon: Icon(Icons.search, 
                  color: Colors.white, 
                  size: _selectedIndex == 3 ? 32 : 28),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard(String title, String subtitle, String imagePath, bool isDoctor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imagePath,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160, color: Colors.grey[200],
                  child: Icon(isDoctor ? Icons.person : Icons.local_hospital, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => const Icon(Icons.star, size: 18, color: Colors.orangeAccent)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}