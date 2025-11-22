import 'package:xd/theme/tema.dart';
import 'package:flutter/material.dart';

class AgendarCitaPage extends StatelessWidget {
  const AgendarCitaPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext contex) {
    return Scaffold(
      backgroundColor: MiTema.blanco,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                Center(
                  child: Text(
                    "Agendar Cita",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: MiTema.negro,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo
                Center(
                  child: Text(
                    "La app en donde encontrarás a los mejores doctores",
                    style: TextStyle(color: MiTema.negro),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Texto secundario
                Center(
                  child: Text(
                    "Tu salud es lo más importante, acude a tus citas médicas",
                    style: TextStyle(color: MiTema.negro),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Campo: Médico
                TextField(
                  decoration: InputDecoration(
                    labelText: "Médico",
                    filled: true,
                    fillColor: MiTema.blanco,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo: Motivo de la consulta
                TextField(
                  decoration: InputDecoration(
                    labelText: "Motivo de la consulta",
                    filled: true,
                    fillColor: MiTema.blanco,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 30),

                // Icono calendario
                Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 80,
                    color: MiTema.negro,
                  ),
                ),

                const SizedBox(height: 30),

                // Campo: Hora de la cita
                TextField(
                  decoration: InputDecoration(
                    labelText: "Hora de la cita",
                    filled: true,
                    fillColor: MiTema.blanco,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Botón Agendar
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MiTema.azulMarino,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Agendar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
