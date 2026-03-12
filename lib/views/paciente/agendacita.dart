import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/theme/tema.dart';

class AgendarCita extends StatefulWidget {
  const AgendarCita({Key? key}) : super(key: key);

  @override
  State<AgendarCita> createState() => _AgendarCitaState();
}

class _AgendarCitaState extends State<AgendarCita> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.gris, // Usando el gris de tu tema
      appBar: AppBar(
        backgroundColor: MiTema.azulOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Para regresar
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            const Text(
              'Agendar cita',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 30),

            // --- TARJETA CALENDARIO (Diciembre) ---
            _buildSectionCard(
              title: 'Diciembre',
              child: _buildCustomCalendar(),
            ),
            
            const SizedBox(height: 25),

            // --- TARJETA HORARIOS ---
            _buildSectionCard(
              title: 'Horarios',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mañana', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 10),
                  _buildTimeGrid([
                    '10:00', '11:00', '12:00', '8:00', '10:30', '10:00', '9:00', '12:30'
                  ]),
                  const SizedBox(height: 15),
                  const Text('Tarde', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 10),
                  _buildTimeGrid([
                    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
                  ], selectedTime: '14:00'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SECCIÓN MOTIVO ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Motivo de la cita',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFCDE0F2), // El color azul claro de tu imagen
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- BOTÓN GUARDAR ---
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: MiTema.azulOscuro,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Estructura de tarjeta blanca para las secciones
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // Generador de cuadrícula de tiempos
  Widget _buildTimeGrid(List<String> times, {String? selectedTime}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
        bool isSelected = time == selectedTime;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? MiTema.azulOscuro : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: MiTema.azulOscuro.withOpacity(0.5), width: 1),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Calendario hecho con código para evitar errores de imagen
  Widget _buildCustomCalendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['D', 'L', 'M', 'M', 'J', 'V', 'S'].map((d) => Text(d, style: const TextStyle(fontSize: 12))).toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: 31,
          itemBuilder: (context, index) {
            int day = index + 1;
            bool isSelected = day == 10;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? MiTema.azulOscuro : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '$day',
                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87),
              ),
            );
          },
        ),
      ],
    );
  }
}