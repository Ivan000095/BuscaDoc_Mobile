import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/expediente_controller.dart'; // Ajusta la ruta si es diferente
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:buscadoc_mobile/views/expedientes/expediente_detalle.dart'; // Ajusta la ruta si es diferente

class ExpedientesView extends StatelessWidget {
  final controller = Get.put(ExpedientesController());

  ExpedientesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: UIUtils.appbar(
        title: "Expedientes", 
        fotoUrl: Globals.fotoPerfilActual, 
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MiTema.azulOscuro,
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(MagicoonRegular.plus, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: MiTema.azulOscuro));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 80), // Padding para que el FAB no tape el último
          itemCount: controller.expedientes.length,
          itemBuilder: (context, index) {
            final exp = controller.expedientes[index];
            bool esPropio = exp.parentesco.toLowerCase() == "yo mismo";
            
            // Usamos la variable global
            String? fotoUsuario = Globals.fotoPerfilActual;
            print("URL DE LA FOTO INTENTANDO CARGAR: ${Globals.webUrl}/storage/$fotoUsuario");
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.to(() => ExpedienteDetalleView(expedienteInicial: exp)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          // Avatar con lógica condicional CORREGIDA
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade100, width: 2),
                              // AQUI ESTÁ LA MAGIA: Concatenamos el webUrl con el storage
                              image: (esPropio && fotoUsuario != null && fotoUsuario.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(fotoUsuario),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (esPropio && fotoUsuario != null && fotoUsuario.isNotEmpty)
                                ? null
                                : Icon(
                                    esPropio ? Icons.person : Icons.family_restroom_rounded,
                                    color: MiTema.azulOscuro,
                                    size: 28,
                                  ),
                          ),
                          const SizedBox(width: 15),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exp.nombreCompleto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: esPropio ? MiTema.azulOscuro.withOpacity(0.1) : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        exp.parentesco.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: esPropio ? MiTema.azulOscuro : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "• ${exp.genero}",
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Indicador de sangre o flecha
                          if (exp.tipoSangre != null && exp.tipoSangre!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Text(
                                exp.tipoSangre!,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _mostrarFormulario(BuildContext context) {
    controller.nombreCtrl.clear();
    controller.fechaNacimiento.value = null;
    controller.genero.value = 'masculino';
    controller.parentescoCtrl.clear();
    controller.sangreVal.value = null; // LIMPIAMOS EL DROPDOWN DE SANGRE
    controller.alergiasCtrl.clear();
    controller.padecimientosCtrl.clear();
    controller.habitosCtrl.clear();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Agregar Familiar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Get.back()),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text("Datos Obligatorios", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    
                    _buildInputLabel("Nombre Completo *"),
                    _buildTextField(controller.nombreCtrl, hint: "Ej. María Pérez Gómez"),
                    
                    _buildInputLabel("Fecha de Nacimiento *"),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: MiTema.azulOscuro)),
                            child: child!,
                          ),
                        );
                        if (picked != null) controller.fechaNacimiento.value = picked;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                              controller.fechaNacimiento.value != null 
                                ? "${controller.fechaNacimiento.value!.day}/${controller.fechaNacimiento.value!.month}/${controller.fechaNacimiento.value!.year}"
                                : "Selecciona una fecha",
                              style: TextStyle(color: controller.fechaNacimiento.value != null ? Colors.black87 : Colors.grey.shade600, fontSize: 15),
                            )),
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade500),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel("Género *"),
                              Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: controller.genero.value,
                                    items: const [
                                      DropdownMenuItem(value: 'masculino', child: Text("Masculino")),
                                      DropdownMenuItem(value: 'femenino', child: Text("Femenino")),
                                      DropdownMenuItem(value: 'otro', child: Text("Otro")),
                                    ],
                                    onChanged: (val) => controller.genero.value = val!,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel("Parentesco *"),
                              _buildTextField(controller.parentescoCtrl, hint: "Ej. Hijo, Madre..."),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Text("Datos Médicos (Opcionales)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    
                    // --- DROPDOWN DE SANGRE ---
                    _buildInputLabel("Tipo de Sangre"),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Selecciona", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          value: controller.sangreVal.value, 
                          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((String tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Row(
                                children: [
                                  const Icon(MagicoonFilled.testTube, color: Colors.red, size: 16),
                                  const SizedBox(width: 10),
                                  Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => controller.sangreVal.value = val,
                        )
                      ),
                    )),
                    
                    _buildInputLabel("Alergias"),
                    _buildTextField(controller.alergiasCtrl, hint: "Ej. Penicilina, Nuez..."),

                    _buildInputLabel("Padecimientos Crónicos"),
                    _buildTextField(controller.padecimientosCtrl, hint: "Ej. Asma, Diabetes..."),

                    _buildInputLabel("Hábitos de Salud"),
                    _buildTextField(controller.habitosCtrl, hint: "Ej. Fuma, Hace ejercicio..."),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- BOTÓN GUARDAR CON GRADIENTE ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 15),
              child: Obx(() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(color: MiTema.azulOscuro.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: controller.isLoading.value ? null : () => controller.guardarExpediente(),
                  icon: controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(MagicoonFilled.checkCircle, color: Colors.white, size: 22),
                  label: controller.isLoading.value
                      ? const SizedBox.shrink()
                      : const Text("GUARDAR EXPEDIENTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                ),
              )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5, top: 15),
      child: Text(texto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}