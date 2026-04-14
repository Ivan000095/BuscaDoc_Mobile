// ignore_for_file: depend_on_referenced_packages

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buscadoc_mobile/model/db.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/views/HomeDashboard.dart';
import 'package:buscadoc_mobile/views/farmacia/lista_farmacias.dart';
import 'package:buscadoc_mobile/views/doctor/lista_doctores.dart';
import 'package:buscadoc_mobile/views/chat/contactos.dart';
import 'package:magicoon_icons/magicoon.dart';

class VistaInicio extends StatefulWidget {
  final String title;
  final String role;
  final String userName;
  final String userFoto;
  final String userEmail;

  const VistaInicio({
    super.key,
    required this.title,
    required this.role,
    required this.userName,
    required this.userFoto,
    required this.userEmail,
  });

  @override
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
        child: Center(
          child: Icon(icon, color: MiTema.blanco, size: 25),
        ),
      ),
    );
  }

  late int currentPage;
  late TabController tabController;
  final List<Color> colors = [MiTema.azulOscuro];

  late List<Doctores> doctores = [];
  bool cargandoDoctores = true;

  late List<Farmacia> farmacias = [];
  bool cargandoFarmacias = true;

  late Database db;
  late int tabs;

  @override
  void initState() {
    super.initState();
    currentPage = 0;

    if (widget.role == 'paciente') {
      tabs = 5;
    } else {
      tabs = 2;
    }

    tabController = TabController(length: tabs, vsync: this);

    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });
    
    _initAsync();
  }

  Future<void> _initAsync() async {
    db = await BaseDatos.abreBD();

    await Future.wait([
      _cargarDoctores(),
      _cargarFarmacias(),
    ]);
  }
  Future<void> _cargarDoctores() async {
    try {
      List<Doctores> listaDoctores = await Doctores.all();
      if (mounted) {
        setState(() {
          doctores = listaDoctores;
          cargandoDoctores = false;
        });
      }
    } catch (e) {
      print('Error cargando doctores: $e');
      if (mounted) {
        setState(() {
          cargandoDoctores = false;
        });
      }
    }
  }
  Future<void> _cargarFarmacias() async {
    setState(() {
      cargandoFarmacias = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Globals.webUrl}/api/farmacias'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> listaData = data['data'];
          
          if (mounted) {
            setState(() {
              farmacias = listaData
                  .map((jsonItem) => Farmacia.fromJson(jsonItem))
                  .toList();
              cargandoFarmacias = false;
            });
          }
        } else {
          print('Error en respuesta API: ${data['message']}');
          if (mounted) {
            setState(() {
              cargandoFarmacias = false;
            });
          }
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        if (mounted) {
          setState(() {
            cargandoFarmacias = false;
          });
        }
      }
    } catch (e) {
      print('Error de red cargando farmacias: $e');
      if (mounted) {
        setState(() {
          cargandoFarmacias = false;
        });
      }
    }
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
        appBar: UIUtils.appbar(
          title: 'BuscaDoc',
          fotoUrl: urlFinal,
        ),
        drawer: UIUtils.buildMenuLateral(
          context,
          userName: widget.userName,
          role: widget.role,
          fotoUrl: widget.userFoto,
          userEmail: widget.userEmail,
        ),
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
          icon: Icon(
            Icons.arrow_upward_rounded,
            color: iconColor,
            size: width,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(50),
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
        children: _getViewsByRole(),
      ),
      child: TabBar(
        controller: tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: MiTema.blanco, width: 4),
          insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        tabs: _getIconsByRole(),
      ),
    );
  }

  List<Widget> _getViewsByRole() {
    if (widget.role == 'paciente') {
      return [
        HomeDashboard(role: widget.role, userName: widget.userName),
        ListaDoctoresView(
          doctores: doctores,
          cargando: cargandoDoctores,
        ),
        ListaFarmaciasView(
          farmacias: farmacias,
          cargando: cargandoFarmacias,
        ),
        
        const Center(child: Text('Mis Citas / Pedidos')),
        ListaContactosView(),
      ];
    } else {
      return [
        HomeDashboard(role: widget.role, userName: widget.userName),
        const Center(child: Text('Mi Agenda / Consultas')),
      ];
    }
  }

  List<Widget> _getIconsByRole() {
    if (widget.role == 'paciente') {
      return [
        _tabItem(icon: MagicoonRegular.home, index: 0),
        _tabItem(icon: MagicoonFilled.stethoscope, index: 1),
        _tabItem(icon: MagicoonFilled.pills, index: 2),
        _tabItem(icon: MagicoonRegular.calendar, index: 3),
        _tabItem(icon: MagicoonRegular.chatDots, index: 4),
      ];
    } else {
      return [
        _tabItem(icon: MagicoonRegular.home, index: 0),
        _tabItem(icon: BootstrapIcons.clipboard2_pulse_fill, index: 1),
      ];
    }
  }
}