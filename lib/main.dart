import 'package:buscadoc_mobile/doctor/vistaentrega.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/iniciosesion.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuscaDoc',
      theme: MiTema.temaApp(context),
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/logo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true); // Para que se repita
        _controller.play(); // Iniciar automáticamente
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.blanco,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controller.value.isInitialized
                ? SizedBox(
                    width: 400,
                    height: 300,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const CircularProgressIndicator(), // Muestra carga mientras inicia

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const InicioSesion()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MiTema.azulOscuro,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Inicio',
                style: GoogleFonts.quicksand(
                  color: MiTema.blanco, 
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}