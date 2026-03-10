import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'menu.dart';
import 'top5.dart';
import 'doctor.dart'; 

class Farmacia extends StatefulWidget {
  const Farmacia({Key? key}) : super(key: key);

  @override
  State<Farmacia> createState() => _FarmaciaState();
}

class _FarmaciaState extends State<Farmacia> {
  // El índice 2 corresponde al icono de medicina (la pastilla)
  int _selectedIndex = 2; 

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
                // --- TARJETA PRINCIPAL FARMACIA ---
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/farmaciag.avif', 
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.local_pharmacy, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Farmacia Guadalajara',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
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

                const SizedBox(height: 20),

                // --- BOTONES DE ACCIÓN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      _buildActionButton('Reseñar', () {}),
                      const SizedBox(width: 20),
                      _buildActionButton('Reportar', () {}),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- LISTA DE RESEÑAS ---
                _buildReviewItem(),
                _buildReviewItem(),

                const SizedBox(height: 120), 
              ],
            ),
          ),

          // --- BARRA DE NAVEGACIÓN (ESTILO DOCTOR) ---
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: MiTema.azulOscuro, size: 30),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/doctor1.jpg'),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Me gusto la forma que me atendio, muy profesional',
                  style: TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 5),
                Row(
                  children: List.generate(4, (index) => Icon(
                    index == 0 ? Icons.star_border : Icons.star,
                    color: Colors.orange, // Cambiado a naranja como en Doctor
                    size: 16,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODO ACTUALIZADO PARA COINCIDIR CON LA VISTA DE DOCTOR
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
            // Home
            IconButton(
              icon: Icon(Icons.home_rounded, 
                  color: Colors.white, 
                  size: _selectedIndex == 0 ? 32 : 28),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Top5()));
              },
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
            // Medicina (Farmacia - Actual)
            IconButton(
              icon: Icon(Icons.medication_rounded, 
                  color: _selectedIndex == 2 ? Colors.cyanAccent : Colors.white, 
                  size: _selectedIndex == 2 ? 32 : 28),
              onPressed: () => setState(() => _selectedIndex = 2),
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
}