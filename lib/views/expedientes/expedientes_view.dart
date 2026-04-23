import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/model/expediente_controller.dart'; 
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:buscadoc_mobile/views/expedientes/expediente_detalle.dart'; 

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
        shape: const CircleBorder(),
        backgroundColor: MiTema.azulOscuro,
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(MagicoonRegular.plus, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: MiTema.azulOscuro));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 80),
          itemCount: controller.expedientes.length,
          itemBuilder: (context, index) {
            final exp = controller.expedientes[index];
            bool esPropio = exp.parentesco.toLowerCase() == "yo mismo";
            
            String? fotoUsuario = Globals.fotoPerfilActual;
            
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
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade100, width: 2),
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
    // 1. Limpiamos los controladores
    controller.nombreCtrl.clear();
    controller.fechaNacimiento.value = null;
    controller.genero.value = 'masculino';
    controller.parentescoCtrl.clear();
    controller.sangreVal.value = null;
    controller.alergiasCtrl.clear();
    controller.padecimientosCtrl.clear();
    controller.habitosCtrl.clear();

    // 2. Variables Reactivas para el Parentesco (Selección Única)
    final RxString parentescoSel = ''.obs;
    final RxBool parentescoOtros = false.obs;

    // 3. Variables Reactivas Locales para los Checklists (Selección Múltiple)
    final RxList<String> alergiasSel = <String>[].obs;
    final RxBool alergiasOtros = false.obs;

    final RxList<String> padecimientosSel = <String>[].obs;
    final RxBool padecimientosOtros = false.obs;

    final RxList<String> habitosSel = <String>[].obs;
    final RxBool habitosOtros = false.obs;

    // 4. Función Mágica para consolidar datos
    void consolidarDatosMedicos() {
      // Consolidar Parentesco
      if (parentescoSel.value.isNotEmpty && parentescoSel.value != 'Otros') {
        controller.parentescoCtrl.text = parentescoSel.value;
      } // Si es 'Otros', conserva lo que el usuario escribió en el TextField

      // Consolidar Listas Médicas
      String procesarLista(List<String> selecciones, bool tieneOtros, String textoOtros) {
        List<String> finales = List.from(selecciones);
        if (tieneOtros) {
          finales.remove('Otros');
          if (textoOtros.trim().isNotEmpty) {
            finales.add(textoOtros.trim());
          }
        }
        return finales.join(', ');
      }

      controller.alergiasCtrl.text = procesarLista(alergiasSel, alergiasOtros.value, controller.alergiasCtrl.text);
      controller.padecimientosCtrl.text = procesarLista(padecimientosSel, padecimientosOtros.value, controller.padecimientosCtrl.text);
      controller.habitosCtrl.text = procesarLista(habitosSel, habitosOtros.value, controller.habitosCtrl.text);
    }

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
                physics: const BouncingScrollPhysics(),
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

                    // GÉNERO (Abarca todo el ancho)
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

                    _buildSingleChoiceSection(
                      titulo: "Parentesco *",
                      opciones: ['Hijo/a', 'Padre/Madre', 'Pareja', 'Hermano/a', 'Otros'],
                      seleccionItem: parentescoSel,
                      mostrarOtros: parentescoOtros,
                      otrosCtrl: controller.parentescoCtrl,
                      hintOtros: "Ej. Abuelo, Sobrino...",
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
                    
                    // --- CHECKLISTS MULTIPLES ---
                    _buildChecklistSection(
                      titulo: "Alergias",
                      opciones: ['Ninguna', 'Penicilina', 'Polen', 'Ácaros', 'Mariscos', 'Nueces', 'Látex', 'Mascotas', 'Otros'],
                      opcionNinguno: 'Ninguna',
                      seleccionesList: alergiasSel,
                      mostrarOtros: alergiasOtros,
                      otrosCtrl: controller.alergiasCtrl,
                      hintOtros: "Especifica qué alergias...",
                    ),

                    _buildChecklistSection(
                      titulo: "Padecimientos Crónicos",
                      opciones: ['Ninguno', 'Diabetes', 'Hipertensión', 'Asma', 'Artritis', 'Obesidad', 'Cardiopatía', 'Otros'],
                      opcionNinguno: 'Ninguno',
                      seleccionesList: padecimientosSel,
                      mostrarOtros: padecimientosOtros,
                      otrosCtrl: controller.padecimientosCtrl,
                      hintOtros: "Especifica qué padecimientos...",
                    ),

                    _buildChecklistSection(
                      titulo: "Hábitos de Salud",
                      opciones: ['Ninguno', 'Fuma', 'Consume alcohol', 'Sedentarismo', 'Ejercicio regular', 'Dieta balanceada', 'Otros'],
                      opcionNinguno: 'Ninguno',
                      seleccionesList: habitosSel,
                      mostrarOtros: habitosOtros,
                      otrosCtrl: controller.habitosCtrl,
                      hintOtros: "Especifica otros hábitos...",
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- BOTÓN GUARDAR ---
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
                  onPressed: controller.isLoading.value 
                    ? null 
                    : () {
                        // Comprobación de campo requerido para el parentesco
                        if (parentescoSel.value.isEmpty) {
                          Get.snackbar('Atención', 'Por favor selecciona un Parentesco.', backgroundColor: Colors.orange.shade100, colorText: Colors.orange.shade900);
                          return;
                        }
                        if (parentescoSel.value == 'Otros' && controller.parentescoCtrl.text.trim().isEmpty) {
                          Get.snackbar('Atención', 'Especifica el parentesco en el campo de texto.', backgroundColor: Colors.orange.shade100, colorText: Colors.orange.shade900);
                          return;
                        }

                        consolidarDatosMedicos();
                        controller.guardarExpediente();
                      },
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

  // --- WIDGET REUTILIZABLE PARA SELECCIÓN MÚLTIPLE (Alergias, Padecimientos...) ---
  Widget _buildChecklistSection({
    required String titulo,
    required List<String> opciones,
    required String opcionNinguno,
    required RxList<String> seleccionesList,
    required RxBool mostrarOtros,
    required TextEditingController otrosCtrl,
    required String hintOtros,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(titulo),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opciones.map((opcion) {
            bool isSelected = seleccionesList.contains(opcion);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (opcion == opcionNinguno) {
                    seleccionesList.clear();
                    if (!isSelected) seleccionesList.add(opcionNinguno);
                    mostrarOtros.value = false;
                  } else {
                    seleccionesList.remove(opcionNinguno); 
                    if (isSelected) {
                      seleccionesList.remove(opcion);
                      if (opcion == 'Otros') mostrarOtros.value = false;
                    } else {
                      seleccionesList.add(opcion);
                      if (opcion == 'Otros') mostrarOtros.value = true;
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? MiTema.azulOscuro : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? MiTema.azulOscuro : Colors.grey.shade300),
                    boxShadow: isSelected 
                      ? [BoxShadow(color: MiTema.azulOscuro.withOpacity(0.3), blurRadius: 6, offset: const Offset(0,3))] 
                      : [],
                  ),
                  child: Text(
                    opcion,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        
        Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: mostrarOtros.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildTextField(otrosCtrl, hint: hintOtros),
                )
              : const SizedBox.shrink(),
        )),
        const SizedBox(height: 10),
      ],
    );
  }

  // --- NUEVO WIDGET PARA SELECCIÓN ÚNICA (Parentesco) ---
  Widget _buildSingleChoiceSection({
    required String titulo,
    required List<String> opciones,
    required RxString seleccionItem,
    required RxBool mostrarOtros,
    required TextEditingController otrosCtrl,
    required String hintOtros,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(titulo),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opciones.map((opcion) {
            bool isSelected = seleccionItem.value == opcion;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  seleccionItem.value = opcion;
                  mostrarOtros.value = (opcion == 'Otros');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? MiTema.azulOscuro : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? MiTema.azulOscuro : Colors.grey.shade300),
                    boxShadow: isSelected 
                      ? [BoxShadow(color: MiTema.azulOscuro.withOpacity(0.3), blurRadius: 6, offset: const Offset(0,3))] 
                      : [],
                  ),
                  child: Text(
                    opcion,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        
        Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: mostrarOtros.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildTextField(otrosCtrl, hint: hintOtros),
                )
              : const SizedBox.shrink(),
        )),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInputLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5, top: 15),
      child: Text(texto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      textCapitalization: TextCapitalization.sentences,
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