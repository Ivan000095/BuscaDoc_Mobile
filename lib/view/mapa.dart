import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xd/theme/tema.dart';

class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  String _latitud = '';
  String _longitud = '';
  String _mensaje = 'Presiona el botón para obtener la ubicación';
  bool _cargando = false;
  Future<void> _obtenerUbicacion() async {
    setState(() {
      _cargando = true;
      _mensaje = "Buscando satélites...";
    });

    try {
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        throw 'El GPS está desactivado. Por favor, enciéndelo.';
      }
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          throw 'Permisos de ubicación denegados.';
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        throw 'Los permisos están denegados permanentemente. Ve a ajustes.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitud = position.latitude.toString();
        _longitud = position.longitude.toString();
        _mensaje = "¡Ubicación encontrada!";
      });

    } catch (e) {
      setState(() {
        _mensaje = "Error: $e";
        _latitud = '';
        _longitud = '';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geolocalización")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 50, color: MiTema.azulMarino),
              const SizedBox(height: 20),
              
              Text(
                _mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              if (_latitud.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text("Latitud: $_latitud", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Longitud: $_longitud", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              _cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _obtenerUbicacion,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Obtener Ubicación Actual"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}