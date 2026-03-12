import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'menu.dart';


class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiTema.blanco,
      drawer: const MenuLateral(),
      appBar: AppBar(
        backgroundColor: MiTema.azulOscuro,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Mi perfil',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            
            // Sección de Foto de Perfil con Asset Local
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/maria.avif', // Imagen cargada desde tus assets
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nombre', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    _buildDisabledInput('Maria P.', width: 140),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            _buildFieldLabel('Foto'),
            _buildFileSelector(),

            const SizedBox(height: 20),
            _buildFieldLabel('Correo electronico'),
            _buildDisabledInput('dhfbebefr@gmail.com'),

            const SizedBox(height: 20),
            _buildFieldLabel('Contraseña'),
            _buildDisabledInput('***********'),

            const SizedBox(height: 20),
            _buildFieldLabel('Fecha de nacimiento'),
            _buildDisabledInput('20-07-06'),

            const SizedBox(height: 50),

            // Botón Editar
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: MiTema.azulOscuro,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildFileSelector() {
    return Container(
      decoration: _inputBoxDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            child: const Text('Seleccionar archivo', style: TextStyle(fontSize: 10)),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text('image2.png', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 10),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildDisabledInput(String text, {double width = double.infinity}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: _inputBoxDecoration(),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}