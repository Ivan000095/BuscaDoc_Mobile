import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'menu.dart';
import 'top5.dart'; 
import 'agendacita.dart'; 
import 'farmacia.dart';

class Doctor extends StatefulWidget {
  const Doctor({Key? key}) : super(key: key);

  @override
  State<Doctor> createState() => _DoctorState();
}

class _DoctorState extends State<Doctor> {
  int _selectedIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.gris,
      drawer: const MenuLateral(),
      appBar: AppBar(
        backgroundColor: MiTema.azulOscuro,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // --- TARJETA PERFIL DOCTOR ---
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/doctor1.jpg',
                          width: 120,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Juan C.',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.assignment, color: MiTema.azulOscuro),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Especialidad:\n• Médico general\n• Ginecólogo',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- BOTONES DE INFORMACIÓN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    children: [
                      _buildInfoItem(Icons.location_on, 'Ubicación'),
                      _buildInfoItem(Icons.access_time, 'Horarios'),
                      _buildInfoItem(Icons.calendar_month, 'Días laborales'),
                      _buildInfoItem(Icons.phone_in_talk, 'Teléfono'),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Reseñas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                // --- BOTONES DE ACCIÓN ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildActionButton('Solicitar cita', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AgendarCita()),
                            );
                          }),
                          const SizedBox(width: 15),
                          _buildActionButton('Enviar mensaje', () {}),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildActionButton('Reseñar', () {}),
                          const SizedBox(width: 15),
                          _buildActionButton('Reportar', () {}),
                        ],
                      ),
                    ],
                  ),
                ),

                _buildReviewItem(),
                _buildReviewItem(),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // --- BARRA DE NAVEGACIÓN ACTUALIZADA ---
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: MiTema.azulOscuro,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, color: Colors.white, size: _selectedIndex == 0 ? 32 : 28),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Top5()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.health_and_safety_rounded, color: Colors.white, size: _selectedIndex == 1 ? 32 : 28),
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                  // 2. NAVEGACIÓN A FARMACIA AGREGADA AQUÍ
                  IconButton(
                    icon: Icon(Icons.medication, color: Colors.white, size: _selectedIndex == 2 ? 32 : 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Farmacia()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white, size: _selectedIndex == 3 ? 32 : 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Los métodos _buildInfoItem, _buildActionButton y _buildReviewItem se mantienen igual...
  Widget _buildInfoItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: MiTema.azulOscuro, size: 28),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: MiTema.azulOscuro,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/doctor1.jpg')),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Me gustó la atención, muy profesional', style: TextStyle(fontSize: 11)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    Icon(Icons.star, color: Colors.orange, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}