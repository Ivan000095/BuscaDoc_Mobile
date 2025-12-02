// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:xd/controller/doctorcontroller.dart';
import 'package:xd/model/doctores.dart';
import 'package:xd/theme/tema.dart';
import 'package:xd/utils/formatos.dart';
import 'package:xd/model/comentarios.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xd/view/citas.dart';

// ignore: must_be_immutable
class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key, required this.doctor});
  final ProductController productController = Get.put(ProductController());
  final Doctores doctor;
  late Database db;

  // Future<List<Doctores>> doctores = Doctores.all(Database db);

  List<Comentario> comentarios = Comentario.all();

  final TextEditingController _controller = TextEditingController();

  Future<List<Doctores>> _doctors() async {
    Future<List<Doctores>> doctores = Doctores.all();
    return doctores;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.azulblanco,
      appBar: AppBar(
        title: Text(doctor.nombre, style: TextStyle(color: Colors.white)),
        backgroundColor: MiTema.azulMarino,
      ),
      body: FutureBuilder<List<Doctores>>(
        future: _doctors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctores = snapshot.data!;
          return _vista(context, doctores); // pásalos a tu vista
        },
      ),
      bottomNavigationBar: _bottom(context),
    );
  }

  Widget _vista(BuildContext context, doctores) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * .35,
          padding: const EdgeInsets.only(bottom: 30, top: 20),
          width: double.infinity,
          child: CircleAvatar(
            radius: 145,
            backgroundImage: AssetImage(doctor.image),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 40, right: 14, left: 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            doctor.nombre,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${Formatos.horario(doctor.horarioentrada)} - ${Formatos.horario(doctor.horariosalida)}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        doctor.descripcion,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _elementos(Icons.phone, doctor.telefono),
                      _elementos(
                        Icons.calendar_month,
                        '${Formatos.fecha(doctor.fecha)} (${Formatos.edad(doctor.fecha)} años)',
                      ),
                      _elementos(Icons.translate, doctor.idioma),
                      _elementos(Icons.house, doctor.direccion),
                      _elementos(
                        Icons.monetization_on_outlined,
                        'costo de consulta ${doctor.costos}',
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Similares',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _similares(doctores),
                      const SizedBox(height: 50),
                      _comentarios(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: MiTema.azulhielo,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottom(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 20),
          Expanded(
            child: Builder(
              builder: (innerContext) {
                return InkWell(
                  onTap: () {
                    Get.to(() => AgendarCitaPage(doctor: doctor));
                  },
                  child: _boton(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _elementos(IconData icono, String contenido) {
    return ListTile(
      leading: Icon(icono, color: MiTema.azulMarino),
      title: Text(contenido),
    );
  }

  Widget _similares(doctores) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: doctores.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(
            right: 20,
            bottom: 5,
            left: 10,
            top: 10,
          ),
          width: 100,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Color of the shadow
                spreadRadius:
                    3, // Extent to which the box is inflated before blur
                blurRadius: 4, // Haziness of the shadow's edges
                offset: Offset(0, 3), // Controls shadow's position (dx, dy)
              ),
            ],
            color: MiTema.blanco,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: <Widget>[
              Image.asset(
                doctores[index].image,
                width: 70,
                height: 65,
              ), // Your image
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  doctores[index].nombre, // Your subtitle text
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comentarios() {
    return Card(
      color: MiTema.blanco,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Comentarios",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comentarios.length,
              itemBuilder: (context, index) {
                final comentario = comentarios[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(comentario.foto),
                        child: null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MiTema.blanco,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            comentario.contenido,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un comentario...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.send, color: MiTema.azulMarino),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _boton() {
    if (Formatos.compararhoras(doctor.horarioentrada, doctor.horariosalida) ==
        false) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          'No disponible',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MiTema.azulMarino,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Obx(
          () => productController.isAddLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'Cita',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    }
  }
}
