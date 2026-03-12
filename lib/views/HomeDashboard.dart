import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buscadoc_mobile/theme/tema.dart'; // Asumiendo que aquí tienes tus colores

class HomeDashboard extends StatefulWidget {
  final String role;
  final String userName;

  const HomeDashboard({
      super.key,
      required this.role,
      required this.userName,
    });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late GoogleMapController mapController;
  final LatLng _centroOcosingo = const LatLng(16.9084, -92.0977);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: _buildBodyByRole(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showChatbot(context),
      //   backgroundColor: MiTema.azulOscuro,
      //   child: const Icon(Icons.robot, color: Colors.white),
      // ),
    );
  }

  Widget _buildBodyByRole() {
    String currentRole = widget.role.toLowerCase(); 
    if (currentRole == 'doctor') {
      return _buildDoctorDashboard();
    } else {
      return _buildPacienteDashboard();
    }
  }


  Widget _buildDoctorDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Panel Médico", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MiTema.azulOscuro)),
          Text("Bienvenido, Dr. ${widget.userName}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          
          const Text("Acciones Rápidas", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildQuickAction("Agenda", Icons.calendar_month, Colors.indigo)),
              const SizedBox(width: 15),
              Expanded(child: _buildQuickAction("Mensajes", Icons.chat_bubble, Colors.teal)),
            ],
          ),
          
          const SizedBox(height: 30),
          const Text("Resumen del día", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildSummaryCard("Siguiente Paciente", "Juan Pérez - 10:30 AM", Icons.person, Colors.green),
          _buildSummaryCard("Última Opinión", "Excelente atención...", Icons.star, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildPacienteDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hola, ${widget.userName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("¿Qué necesitas hoy?", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar cardiólogo, pediatra...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("Matriz de ubicaciones"),
          const SizedBox(height: 10),
          
          // El mapa que tienes en la web
          Container(
            height: 250,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _centroOcosingo, zoom: 13),
                onMapCreated: (controller) => mapController = controller,
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          _buildSectionTitle("Servicios"),
          const SizedBox(height: 15),
          _buildServiceRow(),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildServiceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildServiceIcon(Icons.medical_information, "Doctores"),
        _buildServiceIcon(Icons.chat, "Mensajes"),
        _buildServiceIcon(Icons.history, "Historial"),
      ],
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
          child: Icon(icon, color: MiTema.azulOscuro),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // void _showChatbot(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yimini or chatyipiti...")));
  // }
}