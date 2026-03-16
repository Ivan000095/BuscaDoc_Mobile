import 'package:buscadoc_mobile/views/paciente/doctor.dart';
import 'package:buscadoc_mobile/views/paciente/farmacia.dart';
import 'package:buscadoc_mobile/views/paciente/menu.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';


class Top5 extends StatefulWidget {
  const Top5({Key? key}) : super(key: key);

  @override
  State<Top5> createState() => _Top5State();
}

class _Top5State extends State<Top5> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                
               
                _buildModernCard('Dr. Juan Carlos P. Gomez', 'Cardiólogo', 'assets/doctor1.png', true, () {
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

          
        ],
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