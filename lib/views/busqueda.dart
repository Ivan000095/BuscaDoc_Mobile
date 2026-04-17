import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';
import 'package:buscadoc_mobile/views/farmacia/vistafarmacia.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';

class BusquedaResultados extends StatefulWidget {
  final String query;
  final String type;
  final String? especialidadId;

  const BusquedaResultados({super.key, required this.query, required this.type, this.especialidadId});

  @override
  State<BusquedaResultados> createState() => _BusquedaResultadosState();
}

class _BusquedaResultadosState extends State<BusquedaResultados> {
  List<dynamic> _resultados = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _ejecutarBusqueda();
  }

  Future<void> _ejecutarBusqueda() async {
    try {
      var url = Uri.parse('${Globals.webUrl}/api/buscar?type=${widget.type}&search=${widget.query}&especialidad_id=${widget.especialidadId ?? ""}');
      
      var response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _resultados = data['data'];
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados de ${widget.type == 'doctor' ? 'Doctores' : 'Farmacias'}"),
        backgroundColor: Colors.white,
        foregroundColor: MiTema.azulOscuro,
        elevation: 0,
      ),
      body: _cargando 
        ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
        : _resultados.isEmpty 
          ? const Center(child: Text("No se encontraron resultados"))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                var item = _resultados[index];
                return _buildResultadoCard(item);
              },
            ),
    );
  }

  Widget _buildResultadoCard(dynamic item) {
    String nombre = widget.type == 'doctor' ? item['user']['name'] : item['nom_farmacia'];
    String? rutaFisica = item['user'] != null ? item['user']['foto'] : null;
    String fotoUrl = '';
    if (rutaFisica != null && rutaFisica.isNotEmpty) {
      fotoUrl = rutaFisica.startsWith('http') 
          ? rutaFisica 
          : '${Globals.webUrl}/storage/$rutaFisica';
    }
    String sub = widget.type == 'doctor' ? "Médico Especialista" : "Farmacia Local";

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: MiTema.azulOscuro.withOpacity(0.1),
          backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
          child: fotoUrl.isEmpty 
              ? Icon(widget.type == 'doctor' ? Icons.person : Icons.local_pharmacy, color: MiTema.azulOscuro) 
              : null,
        ),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          if (widget.type == "doctor") {
            Doctores doctorMapeado = Doctores.fromJson(item);
            Get.to(() => DoctorDetailsView(doctor: doctorMapeado));
          } else if (widget.type == "farmacia") {
            Farmacia farmaciaMapeada = Farmacia.fromJson(item);
            Get.to(() => FarmaciaDetailsView(farmacia: farmaciaMapeada));
          }
        },
      ),
    );
  }
}