import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/doctores.dart';
import 'package:buscadoc_mobile/views/doctor/vistadoctor.dart';
import 'package:magicoon_icons/magicoon.dart';

class ListaDoctoresView extends StatefulWidget {
  final List<Doctores> doctores;
  final bool cargando;

  const ListaDoctoresView({
    super.key, 
    required this.doctores, 
    required this.cargando
  });

  @override
  State<ListaDoctoresView> createState() => _ListaDoctoresViewState();
}

class _ListaDoctoresViewState extends State<ListaDoctoresView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    // Escuchamos el teclado para filtrar en tiempo real
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1. OBTENER LISTA DE ESPECIALIDADES ÚNICAS PARA EL DROPDOWN
  List<String> get _especialidadesDisponibles {
    final specs = widget.doctores.map((d) => d.especialidad).toSet().toList();
    specs.sort(); // Ordenadas alfabéticamente
    return specs;
  }

  // 2. FILTRAR Y AGRUPAR LOS DOCTORES
  Map<String, List<Doctores>> get _doctoresFiltradosYAgrupados {
    // Primero filtramos
    var filtrados = widget.doctores.where((doc) {
      final coincideNombre = doc.nombre.toLowerCase().contains(_searchQuery);
      final coincideEspecialidad = _selectedSpecialty == null || _selectedSpecialty == 'Todas' || doc.especialidad == _selectedSpecialty;
      return coincideNombre && coincideEspecialidad;
    }).toList();

    // Luego agrupamos por especialidad
    Map<String, List<Doctores>> agrupados = {};
    for (var doc in filtrados) {
      agrupados.putIfAbsent(doc.especialidad, () => []).add(doc);
    }
    return agrupados;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cargando) {
      return Center(child: CircularProgressIndicator(color: MiTema.azulOscuro));
    }
    
    if (widget.doctores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MagicoonRegular.stethoscope, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 15),
            Text('Aún no hay doctores registrados.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final dataAgrupada = _doctoresFiltradosYAgrupados;
    final especialidadesNombres = dataAgrupada.keys.toList()..sort(); // Ordenar cabeceras A-Z

    return Column(
      children: [
        // TARJETA DE BÚSQUEDA Y FILTRO
        _buildBuscadorFlotante(),

        // LISTA AGRUPADA
        Expanded(
          child: dataAgrupada.isEmpty
            ? Center(
                child: Text('No se encontraron coincidencias.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: especialidadesNombres.length,
                itemBuilder: (context, index) {
                  String especialidad = especialidadesNombres[index];
                  List<Doctores> docsDeEstaEspecialidad = dataAgrupada[especialidad]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ENCABEZADO DE LA ESPECIALIDAD
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10, left: 5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: MiTema.azulOscuro.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(MagicoonFilled.star, color: MiTema.azulOscuro, size: 14),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              especialidad,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                      ),
                      
                      // TARJETAS DE DOCTORES DE ESTA ESPECIALIDAD
                      ...docsDeEstaEspecialidad.map((doctor) => _buildDoctorCard(doctor)),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
        ),
      ],
    );
  }

  // WIDGET: TARJETA DE BÚSQUEDA
  Widget _buildBuscadorFlotante() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 16, right: 16, bottom: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          // Input de texto
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                prefixIcon: const Icon(MagicoonRegular.search, color: Colors.grey, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Dropdown de Especialidades
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedSpecialty,
                hint: Row(
                  children: [
                    Icon(MagicoonRegular.filter, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 10),
                    Text("Todas las especialidades", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  ],
                ),
                icon: const Icon(MagicoonRegular.angleDown, size: 18),
                items: [
                  const DropdownMenuItem(value: 'Todas', child: Text("Todas las especialidades", style: TextStyle(fontWeight: FontWeight.bold))),
                  ..._especialidadesDisponibles.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSpecialty = val;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: TARJETA INDIVIDUAL DE DOCTOR
  Widget _buildDoctorCard(Doctores doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => DoctorDetailsView(doctor: doctor)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // FOTO DEL DOCTOR
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100, width: 2)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      doctor.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF5F7F9),
                        child: Icon(MagicoonFilled.user, size: 40, color: Colors.grey.shade300),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF5F7F9),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: MiTema.azulOscuro)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                
                // INFORMACIÓN DEL DOCTOR
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calificación
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(MagicoonFilled.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            doctor.promedio?.toStringAsFixed(1) ?? '0.0',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      // Nombre
                      Text(
                        doctor.nombre.startsWith("Dr") ? doctor.nombre : "Dr. ${doctor.nombre}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MiTema.azulOscuro),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Horario
                      Row(
                        children: [
                          Icon(MagicoonFilled.clock, color: MiTema.azulOscuro, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              // Si en Laravel se determinó que hoy es descanso, mostramos el mensaje.
                              doctor.horarioentrada == 'Descanso'
                                  ? 'No disponible hoy'
                                  : '${doctor.horarioentrada} - ${doctor.horariosalida} hrs',
                              style: TextStyle(
                                fontSize: 12, 
                                color: doctor.horarioentrada == 'Descanso' ? Colors.red.shade400 : Colors.grey.shade600, 
                                fontWeight: FontWeight.w500
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Precio
                      Row(
                        children: [
                          Icon(MagicoonFilled.wallet, color: const Color(0xFF10B981), size: 15), // Verde
                          const SizedBox(width: 6),
                          Text(
                            '\$${doctor.costos.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
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