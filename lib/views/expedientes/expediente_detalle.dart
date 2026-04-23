import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:buscadoc_mobile/model/expediente.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/model/expediente_detalle_controller.dart';
import 'package:magicoon_icons/magicoon.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class ExpedienteDetalleView extends StatelessWidget {
  final Expediente expedienteInicial;

  const ExpedienteDetalleView({super.key, required this.expedienteInicial});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpedienteDetalleController(expedienteId: expedienteInicial.id));
    bool esPropio = expedienteInicial.parentesco.toLowerCase() == 'yo mismo';
    String? fotoUsuario = Globals.fotoPerfilActual;
    bool tieneFoto = esPropio && fotoUsuario != null && fotoUsuario.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Ficha Médica", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: MiTema.azulOscuro.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_document, color: MiTema.azulOscuro, size: 20),
              onPressed: () => _mostrarFormularioEdicion(context, controller),
              tooltip: "Editar Expediente",
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: MiTema.azulOscuro));
        }

        final exp = controller.expediente.value ?? expedienteInicial;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TARJETA DE PERFIL (Rediseñada con Gradiente)
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MiTema.azulOscuro, MiTema.azulOscuro.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: MiTema.azulOscuro.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      padding: tieneFoto ? EdgeInsets.zero : const EdgeInsets.all(15), 
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        image: tieneFoto
                            ? DecorationImage(
                                image: NetworkImage(fotoUsuario!), 
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: tieneFoto
                          ? null
                          : const Icon(Icons.person_outline, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.nombreCompleto, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "${exp.parentesco.toUpperCase()} • ${exp.genero}", 
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.cake_outlined, color: Colors.white70, size: 14),
                              const SizedBox(width: 5),
                              Text("Nacimiento: ${exp.fechaNacimiento}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // 2. DATOS CLÍNICOS (Tarjetas flotantes individuales)
              const Text("Datos Clínicos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              _buildInfoCard(Icons.water_drop, "Tipo de Sangre", exp.tipoSangre ?? "No especificado", Colors.red),
              _buildInfoCard(Icons.warning_amber_rounded, "Alergias", exp.alergias ?? "Ninguna reportada", Colors.orange),
              _buildInfoCard(Icons.medical_services_outlined, "Padecimientos", exp.padecimientos ?? "Ninguno reportado", Colors.blue),
              _buildInfoCard(Icons.directions_run, "Hábitos", exp.habitos ?? "No especificados", Colors.green),
              
              const SizedBox(height: 35),

              // 3. HISTORIAL DE CONSULTAS
              const Text("Historial de Consultas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              if (controller.notasMedicas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.history_edu, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      Text("Aún no hay historial clínico", style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Las notas de los doctores aparecerán aquí.", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.notasMedicas.length,
                  itemBuilder: (context, index) {
                    var nota = controller.notasMedicas[index];
                    DateTime fecha = DateTime.parse(nota['created_at']);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        border: const Border(left: BorderSide(color: Colors.green, width: 5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("Nota Médica", style: TextStyle(fontWeight: FontWeight.bold, color: MiTema.azulOscuro, fontSize: 14)),
                                ],
                              ),
                              Text(DateFormat('dd MMM yyyy').format(fecha), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                          Text(nota['diagnostico'] ?? '', style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.5)),
                        ],
                      ),
                    );
                  },
                ),
                
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // NUEVO DISEÑO PARA LAS FILAS CLÍNICAS (Tarjetas Flotantes)
  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value.isNotEmpty ? value : "No especificado", style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

 void _mostrarFormularioEdicion(BuildContext context, ExpedienteDetalleController controller) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.90,
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Editar Expediente", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    const Text("Datos Personales", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    
                    _buildInputLabel("Nombre Completo *"),
                    _buildTextField(controller.nombreCtrl),
                    
                    _buildInputLabel("Fecha de Nacimiento *"),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: controller.fechaNacimiento.value ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
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
                                  )
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
                              _buildTextField(controller.parentescoCtrl),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text("Datos Clínicos", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    
                    // --- NUEVO DROPDOWN DE SANGRE ---
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
                    _buildTextField(controller.alergiasCtrl),
                    _buildInputLabel("Padecimientos Crónicos"),
                    _buildTextField(controller.padecimientosCtrl),
                    _buildInputLabel("Hábitos de Salud"),
                    _buildTextField(controller.habitosCtrl),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // --- NUEVO BOTÓN DE GUARDAR CON GRADIENTE Y MAGICOONS ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 15),
              child: Obx(() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MiTema.azulOscuro, const Color(0xFF1E3A8A)], // Gradiente elegante
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
                    backgroundColor: Colors.transparent, // Transparente para que se vea el gradiente
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: controller.isSaving.value ? null : () => controller.guardarEdicion(),
                  icon: controller.isSaving.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(MagicoonFilled.checkCircle, color: Colors.white, size: 22),
                  label: controller.isSaving.value 
                      ? const SizedBox.shrink()
                      : const Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
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

  Widget _buildTextField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}