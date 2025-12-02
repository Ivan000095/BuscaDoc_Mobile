import 'package:file_picker/file_picker.dart';
import 'package:xd/model/doctores.dart';
import 'package:xd/theme/tema.dart';
import 'package:flutter/material.dart';

class AgendarCitaPage extends StatelessWidget {
  AgendarCitaPage({super.key, required this.doctor});
  final Doctores doctor;
  final TextEditingController _ctrlArchivo = TextEditingController();


  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      _ctrlArchivo.text = file.name; 
    }
  }

  @override
  Widget build(BuildContext contex) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.nombre, style: TextStyle(color: Colors.white)),
        backgroundColor: MiTema.azulMarino,
      ),
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
                    "Agendar Cita a ${doctor.nombre}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MiTema.negro,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 80,
                    color: MiTema.negro,
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

                const SizedBox(height: 30,),

                TextField(
                  controller: _ctrlArchivo, // Muestra el nombre aquí
                  readOnly: true, // ⚠️ IMPORTANTE: Bloquea el teclado
                  onTap: _seleccionarArchivo, // Al tocar, abre el selector
                  decoration: InputDecoration(
                    labelText: "Adjuntar archivo (PDF, JPG...)", // Tu etiqueta
                    filled: true,
                    fillColor: MiTema.blanco, // Tu color
                    prefixIcon: const Icon(Icons.attach_file), // Icono opcional
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50), // Tu borde redondo
                      borderSide: BorderSide(color: MiTema.azulavanda), // O el color que uses
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: MiTema.negro, width: 2),
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
