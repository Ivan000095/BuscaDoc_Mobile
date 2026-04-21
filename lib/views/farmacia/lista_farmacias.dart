import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/farmacia.dart';
import 'package:buscadoc_mobile/views/farmacia/vistafarmacia.dart';
import 'package:magicoon_icons/magicoon.dart';

class ListaFarmaciasView extends StatefulWidget {
  final List<Farmacia> farmacias;
  final bool cargando;

  const ListaFarmaciasView({
    super.key, 
    required this.farmacias, 
    required this.cargando
  });

  @override
  State<ListaFarmaciasView> createState() => _ListaFarmaciasViewState();
}

class _ListaFarmaciasViewState extends State<ListaFarmaciasView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Escuchamos el texto para actualizar el estado en tiempo real
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

  // Filtrado de farmacias por nombre
  List<Farmacia> get _farmaciasFiltradas {
    if (_searchQuery.isEmpty) {
      return widget.farmacias;
    }
    return widget.farmacias.where((farmacia) {
      return farmacia.nombre.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cargando) {
      return Center(
        child: CircularProgressIndicator(
          color: MiTema.azulOscuro,
        ),
      );
    }
    
    if (widget.farmacias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MagicoonRegular.store, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 15),
            Text(
              'Aún no hay farmacias registradas.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final filtradas = _farmaciasFiltradas;

    return Column(
      children: [
        // TARJETA DE BÚSQUEDA
        _buildBuscadorFlotante(),

        // LISTA DE FARMACIAS
        Expanded(
          child: filtradas.isEmpty
            ? Center(
                child: Text(
                  'No se encontraron coincidencias.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: filtradas.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15), 
                itemBuilder: (context, index) {
                  final farmacia = filtradas[index];
                  return _buildFarmaciaCard(farmacia);
                },
              ),
        ),
      ],
    );
  }

  // WIDGET: BARRA DE BÚSQUEDA
  Widget _buildBuscadorFlotante() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 16, right: 16, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
        ]
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Buscar farmacia por nombre...",
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: const Icon(MagicoonRegular.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus(); // Oculta el teclado
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F7F9), // Fondo sutil para el input
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // WIDGET: TARJETA DE LA FARMACIA
  Widget _buildFarmaciaCard(Farmacia farmacia) {
    return Container(
      decoration: BoxDecoration(
        color: MiTema.blanco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => FarmaciaDetailsView(farmacia: farmacia));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // IMAGEN
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network( 
                      farmacia.imagen ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Container(
                            color: const Color(0xFFF5F7F9),
                            child: Icon(MagicoonFilled.shoppingBag, size: 40, color: Colors.grey.shade300),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF5F7F9),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: MiTema.azulOscuro),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                
                // DATOS DE LA FARMACIA
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
                            farmacia.promedio?.toStringAsFixed(1) ?? '0.0',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      // Nombre
                      Text(
                        farmacia.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MiTema.azulOscuro,
                        ),
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
                              '${farmacia.horarioEntrada} - ${farmacia.horarioSalida}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Teléfono
                      Row(
                        children: [
                          Icon(MagicoonFilled.phone, color: MiTema.azulOscuro, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              farmacia.telefono,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // RFC
                      Row(
                        children: [
                          Icon(MagicoonFilled.fileCheck, color: MiTema.azulOscuro, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              farmacia.rfc ?? 'N/A',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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