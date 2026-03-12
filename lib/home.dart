// ignore_for_file: depend_on_referenced_packages

import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:buscadoc_mobile/model/db.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/model/entrega.dart';
import 'package:buscadoc_mobile/views/doctor/menu.dart';
import 'package:buscadoc_mobile/views/HomeDashboard.dart';
import 'package:buscadoc_mobile/views/farmacia/lista_farmacias.dart';
import 'package:buscadoc_mobile/views/doctor/lista_doctores.dart';
// import 'package:get/get.dart';
// import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';
// import 'package:buscadoc_mobile/views/doctor/mapa.dart';
// import 'package:buscadoc_mobile/utils/formatos.dart';
// import 'package:buscadoc_mobile/views/doctor/vistaentrega.dart';


class VistaInicio extends StatefulWidget {
  final String title;
  final String role;
  final String userName;
  final String userFoto;

  const VistaInicio({
    super.key,
    required this.title,
    required this.role,
    required this.userName,
    required this.userFoto
    });

  @override
  // ignore: library_private_types_in_public_api
  _VistaInicioState createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio>
  with SingleTickerProviderStateMixin {
  Widget _tabItem({required IconData icon, required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentPage = index;
        });
        tabController.animateTo(index);
      },
      child: SizedBox(
        height: 55,
        width: 40,
        child: Center(child: Icon(icon, color: MiTema.blanco)),
      ),
    );
  }

  late int currentPage;
  late TabController tabController;
  final List<Color> colors = [MiTema.azulOscuro];
  late List<Entrega> entregas;
  late List<Doctores> doctores = [];
  late Database db;

  bool cargandoDoctores = true;

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    tabController = TabController(length: 5, vsync: this);

    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });
    entregas = Entrega.all();
    _initAsync();
  }

  Future<void> _initAsync() async {
    db = await BaseDatos.abreBD();
    await _doctors();
  }

  Future<void> _doctors() async {
    List<Doctores> doctores = await Doctores.all();
    setState(() {
      this.doctores = doctores;
      cargandoDoctores = false;
    });
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String urlFinal = widget.userFoto; 

    return SafeArea(
      child: Scaffold(
        appBar: UIUtils.appbar(title: 'Buscamots', fotoUrl: urlFinal),
        drawer: menu(context),
        body: _bottom(),
      ),
    );
  }

  Widget _bottom() {
    final Color barColor = MiTema.azulOscuro;
    final Color iconColor = MiTema.blanco;
    return BottomBar(
      fit: StackFit.expand,
      icon: (width, height) => Center(
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: null,
          icon: Icon(Icons.arrow_upward_rounded, color: iconColor, size: width),
        ),
      ),
      borderRadius: BorderRadius.circular(500),
      duration: Duration(seconds: 1),
      curve: Curves.decelerate,
      showIcon: true,
      width: MediaQuery.of(context).size.width * 0.8,
      barColor: barColor,
      start: 2,
      end: 0,
      offset: 10,
      barAlignment: Alignment.bottomCenter,
      iconHeight: 35,
      iconWidth: 35,
      reverse: false,
      hideOnScroll: true,
      scrollOpposite: false,
      respectSafeArea: true,
      onBottomBarHidden: () {},
      onBottomBarShown: () {},
      body: (context, controller) => TabBarView(
        controller: tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeDashboard(role: widget.role, userName: widget.userName),
          ListaDoctoresView(doctores: doctores, cargando: cargandoDoctores),
          const ListaFarmaciasView(),
          const Center(child: Text('Mis Citas / Entregas')),
          const Center(child: Text('Configuración')),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: MiTema.blanco, width: 4),
          insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        tabs: [
          _tabItem(icon: Icons.home, index: 0),
          _tabItem(icon: Icons.medical_services, index: 1),
          _tabItem(icon: Icons.local_pharmacy, index: 2),
          _tabItem(icon: Icons.calendar_month, index: 3),
          _tabItem(icon: Icons.settings, index: 4),
        ],
      ),
    );
  }
}
//   Widget _pagina1() {

//     if (cargandoDoctores) {
//       return Center(
//         child: CircularProgressIndicator(
//           color: MiTema.azulOscuro,
//         ),
//       );
//     }
//     if (doctores.isEmpty) {
//       return Center(
//         child: Text(
//           'Aún no hay doctores registrados.',
//           style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//         ),
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
//       itemCount: doctores.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 18), 
//       itemBuilder: (context, index) {
//         final doctor = doctores[index];
//         return Container(
//           height: 140,
//           decoration: BoxDecoration(
//             color: MiTema.blanco,
//             borderRadius: BorderRadius.circular(25),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(25),
//               onTap: () {
//                 Get.to(() => DoctorDetailsView(doctor: doctor));
//               },
//               child: Row(
//                 children: [
//                   Container(
//                     width: 110,
//                     height: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(25),
//                         bottomLeft: Radius.circular(25),
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(25),
//                         bottomLeft: Radius.circular(25),
//                       ),
//                       child: Image.network( 
//                         doctor.image,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => 
//                             const Icon(Icons.person, size: 50, color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               for (int i = 0; i < 5; i++)
//                                 Icon(
//                                   i < (doctor.promedio ?? 0).round() 
//                                       ? Icons.star 
//                                       : Icons.star_border,
//                                   color: MiTema.azulOscuro, 
//                                   size: 18
//                                 ),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.assignment_ind, color: MiTema.azulOscuro, size: 18),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       doctor.especialidad,
//                                       style: TextStyle(
//                                         fontSize: 13, 
//                                         color: Colors.grey.shade700,
//                                         fontWeight: FontWeight.w500
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 6),
//                               Row(
//                                 children: [
//                                   Icon(Icons.insert_drive_file_sharp, color: MiTema.azulOscuro, size: 18),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       doctor.descripcion,
//                                       style: TextStyle(
//                                         fontSize: 13, 
//                                         color: Colors.grey.shade700,
//                                         fontWeight: FontWeight.w500
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Text(
//                             doctor.nombre,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: MiTema.azulOscuro,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _pagina2() {
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [_fotoDoc(), _nombreDoc(), _correoDoc(), _emailDoc()],
//       ),
//     );
//   }

//   Widget _fotoDoc() {
//     return Icon(Icons.person_pin, size: 150, color: MiTema.azulOscuro);
//   }

//   Widget _nombreDoc() {
//     return const Text('Berenice', style: TextStyle(fontSize: 20));
//   }

//   Widget _correoDoc() {
//     return ListTile(
//       leading: Icon(Icons.phone, size: 30),
//       title: Text('919-135-8054', style: TextStyle(fontSize: 15)),
//       onTap: () {
//         SnackBar mensaje = const SnackBar(
//           content: Text(
//             'nigger nigger nigger nigger nigger nigger nigger nigger nigger ',
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(mensaje);
//       },
//     );
//   }

//   Widget _emailDoc() {
//     return ListTile(
//       leading: Icon(Icons.email, size: 30),
//       title: Text('berenice@gmail.com', style: TextStyle(fontSize: 15)),
//       onTap: () {
//         SnackBar mensaje = const SnackBar(
//           content: Text(
//             'nigger nigger nigger nigger nigger nigger nigger nigger nigger ',
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(mensaje);
//       },
//     );
//   }

//   Widget _pagina3() {
//     return ListView.separated(
//       padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
//       itemBuilder: (context, index) {
//         return ListTile(
//           tileColor: index % 2 == 0 ? MiTema.azul : MiTema.blanco,
//           minVerticalPadding: 40,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(color: MiTema.azul, width: 2),
//           ),
//           leading: Text(
//             '${entregas[index].numero}',
//             style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
//           ),
//           title: Text(
//             Formatos.fecha(entregas[index].fecha),
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           subtitle: Text(
//             entregas[index].descripcion,
//             textAlign: TextAlign.center,
//           ),
//           trailing: _statusEntrega(entregas[index].fecha),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const VistaEntrega(title: 'Detalle de Entrega'),
//                 settings: RouteSettings(arguments: entregas[index]), // Pasas el objeto aquí
//               ),
//             );
//           },
//         );
//       },
//       separatorBuilder: (context, index) {
//         return Divider(color: Theme.of(context).colorScheme.secondary);
//       },
//       itemCount: entregas.length,
//     );
//   }

//   Widget _pagina4() {
//     return const UbicacionScreen();
//   }

//   Widget _statusEntrega(DateTime fechaentrega) {
//     IconData data = Formatos.comparaFechaHoy(fechaentrega) > 0
//         ? Icons.alarm_off
//         : (Formatos.comparaFechaHoy(fechaentrega) == 0
//               ? Icons.pending_actions
//               : Icons.calendar_month_rounded);
//     String txt = Formatos.comparaFechaHoy(fechaentrega) > 0
//         ? 'Fuera de tiempo'
//         : (Formatos.comparaFechaHoy(fechaentrega) == 0
//               ? 'A tiempo'
//               : 'pendejo');

//     return Column(
//       children: [
//         Icon(data, color: MiTema.azulOscuro, size: 35),
//         Text(txt),
//       ],
//     );
//   }
// }

// class InfiniteListPage extends StatelessWidget {
//   final ScrollController controller;
//   final Color color;

//   const InfiniteListPage({
//     super.key,
//     required this.controller,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       controller: controller,
//       itemCount:
//           50,
//       itemBuilder: (context, index) {
//         return Container(
//           height: 120,
//           // ignore: deprecated_member_use
//           color: index.isEven ? color.withOpacity(0.6) : color.withOpacity(0.8),
//           child: Center(
//             child: Text(
//               'Item $index',
//               style: const TextStyle(
//                 fontSize: 22,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }