// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xd/model/db.dart';
import 'package:xd/theme/tema.dart';
import 'package:xd/model/doctores.dart';
import 'package:xd/model/entrega.dart';
import 'package:xd/utils/formatos.dart';
import 'package:xd/view/citas.dart';
import 'package:xd/view/menu.dart';
import 'package:xd/view/vistadoctor.dart';
import 'package:get/get.dart';
import 'package:flutter_product_card/flutter_product_card.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key, required this.title});
  final String title;

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
        child: Center(child: Icon(icon, color: MiTema.azulMarino)),
      ),
    );
  }

  late int currentPage;
  late TabController tabController;
  final List<Color> colors = [MiTema.azulMarino];
  late List<Entrega> entregas;
  late List<Doctores> doctores = [];
  late Database db;

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: MiTema.azulMarino,
        ),
        drawer: menu(context),
        body: _bottom(),
      ),
    );
  }

  Widget _bottom() {
    final Color barColor = MiTema.azulhielo;
    final Color iconColor = MiTema.azulMarino;
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
          _pagina1(),
          _pagina2(),
          _pagina3(),
          _pagina4(),
          Center(child: Text('Configuración')),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: MiTema.azulMarino, width: 4),
          insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        indicatorColor: Colors.transparent, // evita la línea por defecto
        dividerColor: Colors.transparent,
        tabs: [
          _tabItem(icon: Icons.home, index: 0),
          _tabItem(icon: Icons.search, index: 1),
          _tabItem(icon: Icons.add, index: 2),
          _tabItem(icon: Icons.favorite, index: 3),
          _tabItem(icon: Icons.settings, index: 4),
        ],
      ),
    );
  }

  Widget _pagina1() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
      itemBuilder: (context, index) {
        return ProductCard(
          imageUrl: doctores[index].image,
          categoryName: doctores[index].especialidad,
          productName: doctores[index].nombre,
          horarios:
              '${Formatos.horario(doctores[index].horarioentrada)} - ${Formatos.horario(doctores[index].horariosalida)}',
          currency: '',
          onTap: () {
            Get.to(() => ProductDetailsView(doctor: doctores[index]));
          },
          onFavoritePressed: () {},
          shortDescription: doctores[index].descripcion.length > 60
              ? '${doctores[index].descripcion.substring(0, 60)}...'
              : doctores[index].descripcion,
          rating: 4.2,
          discountPercentage: 35.0,
          isAvailable: Formatos.compararhoras(
            doctores[index].horarioentrada,
            doctores[index].horariosalida,
          ),
          cardColor: MiTema.blanco,
          textColor: Colors.black,
          borderRadius: 20.0,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(color: Colors.transparent);
      },
      itemCount: doctores.length,
    );
  }

  Widget _pagina2() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_fotoDoc(), _nombreDoc(), _correoDoc(), _emailDoc()],
      ),
    );
  }

  Widget _fotoDoc() {
    return Icon(Icons.person_pin, size: 150, color: MiTema.negro);
  }

  Widget _nombreDoc() {
    return const Text('Berenice', style: TextStyle(fontSize: 20));
  }

  Widget _correoDoc() {
    return ListTile(
      leading: Icon(Icons.phone, size: 30),
      title: Text('919-135-8054', style: TextStyle(fontSize: 15)),
      onTap: () {
        SnackBar mensaje = const SnackBar(
          content: Text(
            'nigger nigger nigger nigger nigger nigger nigger nigger nigger ',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(mensaje);
      },
    );
  }

  Widget _emailDoc() {
    return ListTile(
      leading: Icon(Icons.email, size: 30),
      title: Text('berenice@gmail.com', style: TextStyle(fontSize: 15)),
      onTap: () {
        SnackBar mensaje = const SnackBar(
          content: Text(
            'nigger nigger nigger nigger nigger nigger nigger nigger nigger ',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(mensaje);
      },
    );
  }

  Widget _pagina3() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 30),
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: index % 2 == 0 ? MiTema.azulhielo : MiTema.azulgrisaceo,
          minVerticalPadding: 40,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: MiTema.azulhielo, width: 2),
          ),
          leading: Text(
            '${entregas[index].numero}',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          title: Text(
            Formatos.fecha(entregas[index].fecha),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            entregas[index].descripcion,
            textAlign: TextAlign.center,
          ),
          trailing: _statusEntrega(entregas[index].fecha),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/vistaentrega',
              arguments: entregas[index],
            );
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider(color: Theme.of(context).colorScheme.secondary);
      },
      itemCount: entregas.length,
    );
  }

  Widget _pagina4() {
    return const AgendarCitaPage(title: 'buscadoc');
  }

  Widget _statusEntrega(DateTime fechaentrega) {
    IconData data = Formatos.comparaFechaHoy(fechaentrega) > 0
        ? Icons.alarm_off
        : (Formatos.comparaFechaHoy(fechaentrega) == 0
              ? Icons.pending_actions
              : Icons.calendar_month_rounded);
    String txt = Formatos.comparaFechaHoy(fechaentrega) > 0
        ? 'Fuera de tiempo'
        : (Formatos.comparaFechaHoy(fechaentrega) == 0
              ? 'A tiempo'
              : 'pendejo');

    return Column(
      children: [
        Icon(data, color: MiTema.azulMarino, size: 35),
        Text(txt),
      ],
    );
  }
}

class InfiniteListPage extends StatelessWidget {
  final ScrollController controller;
  final Color color;

  const InfiniteListPage({
    super.key,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount:
          50, // puedes poner null para hacerlo infinito, pero esto evita loops
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          // ignore: deprecated_member_use
          color: index.isEven ? color.withOpacity(0.6) : color.withOpacity(0.8),
          child: Center(
            child: Text(
              'Item $index',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
