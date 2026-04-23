import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/citas_controller.dart';
import 'package:magicoon_icons/magicoon.dart';
class MisCitasView extends StatelessWidget {
  final String role;
  // Inyectamos el controlador
  final CitasController controller = Get.put(CitasController());
  MisCitasView({super.key, required this.role});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "Mis Citas Médicas",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: MiTema.azulOscuro),
          );
        }
        if (controller.citasList.isEmpty) {
          return _buildEmptyState();
        }
        
        DateTime hoy = DateTime.now();
        DateTime hoyDate = DateTime(hoy.year, hoy.month, hoy.day);
        List<dynamic> activas = [];
        List<dynamic> historial = [];
        for (var cita in controller.citasList) {
          String fechaLimpia = cita['fecha'].toString().split('T')[0];
          DateTime dateOnly = DateTime.parse(fechaLimpia);
          String estado = cita['estado'] ?? 'pendiente';
          bool isFinal = ['finalizada', 'no asistida', 'cancelada', 'rechazada'].contains(estado);
          if (isFinal || dateOnly.isBefore(hoyDate)) {
            historial.add(cita);
          } else {
            activas.add(cita);
          }
        }
        historial.sort((a, b) {
          String soloFechaA = a['fecha'].toString().split('T')[0];
          String soloFechaB = b['fecha'].toString().split('T')[0];
          DateTime dtA = DateTime.parse("$soloFechaA ${a['hora_inicio']}");
          DateTime dtB = DateTime.parse("$soloFechaB ${b['hora_inicio']}");
          return dtB.compareTo(dtA);
        });
        Map<String, List<dynamic>> activasGrouped = {};
        for (var cita in activas) {
          String dateKey = cita['fecha'].toString().split('T')[0];
          activasGrouped.putIfAbsent(dateKey, () => []).add(cita);
        }
        var sortedKeys = activasGrouped.keys.toList()..sort();
       
        List<Widget> listItems = [];
        if (sortedKeys.isNotEmpty) {
          for (var dateStr in sortedKeys) {
            listItems.add(_buildDateHeader(dateStr));
            for (var cita in activasGrouped[dateStr]!) {
              listItems.add(_buildCitaCard(context, cita, isHistorial: false));
            }
          }
        }
        if (historial.isNotEmpty) {
          listItems.add(_buildHistorialHeader());
          for (var cita in historial) {
            listItems.add(_buildCitaCard(context, cita, isHistorial: true));
          }
        }
        return Stack(
          children: [
            RefreshIndicator(
              color: MiTema.azulOscuro,
              onRefresh: () => controller.fetchCitas(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: 100, 
                ),
                children: listItems,
              ),
            ),
            if (controller.isActionLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(color: MiTema.azulOscuro),
                ),
              ),
          ],
        );
      }),
    );
  }
  
  Widget _buildDateHeader(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime hoy = DateTime.now();
    DateTime hoyDate = DateTime(hoy.year, hoy.month, hoy.day);
    DateTime mananaDate = hoyDate.add(const Duration(days: 1));
    DateTime targetDate = DateTime(date.year, date.month, date.day);
    String etiquetaDia;
    Color colorEtiqueta;
    if (targetDate.isAtSameMomentAs(hoyDate)) {
      etiquetaDia = 'Hoy';
      colorEtiqueta = Colors.blue.shade700;
    } else if (targetDate.isAtSameMomentAs(mananaDate)) {
      etiquetaDia = 'Mañana';
      colorEtiqueta = Colors.cyan.shade700;
    } else {
      etiquetaDia = DateFormat('EEEE', 'es_ES').format(date);
      etiquetaDia = etiquetaDia[0].toUpperCase() + etiquetaDia.substring(1);
      colorEtiqueta = MiTema.azulOscuro;
    }
    String fechaCompleta = DateFormat('d \'de\' MMMM', 'es_ES').format(date);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 15),
      child: Row(
        children: [
          Text(
            etiquetaDia,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorEtiqueta,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            fechaCompleta,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
        ],
      ),
    );
  }
  Widget _buildHistorialHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 35, bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(MagicoonRegular.clock, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                  "HISTORIAL DE CONSULTAS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
        ],
      ),
    );
  }


  Widget _buildCitaCard(BuildContext context, Map<String, dynamic> cita, {required bool isHistorial}) {
    DateTime dtHora = DateFormat("HH:mm:ss").parse(cita['hora_inicio']);
    String amPm = DateFormat('a').format(dtHora);
    String horaStr = DateFormat('hh:mm').format(dtHora);

    String nombreMostrar = '';
    String? fotoMostrar;
    String subtitleMostrar = '';
    String infoExtra = ''; 

    if (role == 'doctor') {
      var exp = cita['expediente'];
      nombreMostrar = exp?['nombre_completo'] ?? 'Paciente no registrado';
      fotoMostrar = exp?['user']?['foto']; 
      String parentesco = exp?['parentesco'] ?? 'Paciente';
      subtitleMostrar = parentesco == 'Yo mismo' ? 'Paciente de plataforma' : parentesco;
      
      if (exp != null && exp['fecha_nacimiento'] != null) {
        DateTime dob = DateTime.parse(exp['fecha_nacimiento']);
        int age = DateTime.now().year - dob.year;
        String genero = exp['genero'] ?? '';
        genero = genero.isNotEmpty ? genero[0].toUpperCase() + genero.substring(1) : '';
        infoExtra = "$age años • $genero";
      }
    } else {
      String docName = cita['doctor']?['user']?['name'] ?? '';
      nombreMostrar = "Dr. $docName";
      fotoMostrar = cita['doctor']?['user']?['foto'];
      subtitleMostrar = cita['doctor']?['especialidades']?[0]?['nombre'] ?? 'Especialista';
    }

    Color blockColor = MiTema.azulOscuro; // Mantenemos tu azul original

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white, // 1. Fondo SIEMPRE blanco y sólido para bloquear la sombra
        borderRadius: BorderRadius.circular(20),
        border: isHistorial ? Border.all(color: Colors.grey.shade200) : null,
        // 2. Si es historial, quitamos la sombra para que se vea plana en el fondo
        boxShadow: isHistorial ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      // 3. LA MAGIA: Aplicamos opacidad y filtro B/N solo a los "hijos" de la tarjeta
      child: Opacity(
        opacity: isHistorial ? 0.6 : 1.0, // Foco visual apagado
        child: ColorFiltered(
          colorFilter: isHistorial 
              // Matriz fotográfica que convierte todo a escala de grises
              ? const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ])
              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TICKET HORA
                Container(
                  width: 85,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(amPm, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(horaStr, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text("Hora", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),

                // INFORMACIÓN Y ESTADOS
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: blockColor.withOpacity(0.1),
                              backgroundImage: fotoMostrar != null ? NetworkImage('${Globals.webUrl}/storage/$fotoMostrar') : null,
                              child: fotoMostrar == null
                                  ? Icon(role == 'doctor' ? MagicoonFilled.user : MagicoonFilled.stethoscope, color: blockColor)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        role == 'doctor' ? MagicoonFilled.folder : MagicoonFilled.stethoscope,
                                        size: 12,
                                        color: blockColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          subtitleMostrar,
                                          style: TextStyle(color: blockColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    nombreMostrar,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  if (infoExtra.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(infoExtra, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // ÁREA INFERIOR DE ESTADO Y BOTONES
                        _buildStatusArea(context, cita, isHistorial),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ==========================================
  // ÁREA DE ESTADOS CONTROLADA POR EL ROL
  // ==========================================
  Widget _buildStatusArea(BuildContext context, Map<String, dynamic> cita, bool isHistorial) {
    
    // ------------------------------------------
    // VISTA DEL DOCTOR: Solo información y Estatus
    // ------------------------------------------
    if (role == 'doctor') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 25, color: Color(0xFFF0F0F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEstadoBadge(cita['estado']),
              if (isHistorial && ['cancelada', 'finalizada', 'rechazada', 'no asistida'].contains(cita['estado']))
                InkWell(
                  onTap: () => _confirmarEliminacion(context, cita['id']),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(border: Border.all(color: Colors.red.shade200), shape: BoxShape.circle),
                    child: Icon(MagicoonRegular.trash, color: Colors.red.shade400, size: 14),
                  ),
                ),
            ],
          ),
        ],
      );
    }


    var solicitudRecibida = cita['solicitud_recibida'];
    var solicitudEnviada = cita['solicitud_enviada'];
    bool yaSeReprogramo = cita['reprogramada'] == 1 || cita['reprogramada'] == true;
    bool yaPropusoCambio = cita['ya_propuso_cambio'] == 1 || cita['ya_propuso_cambio'] == true;
    bool puedeReagendarDirecto = (cita['estado'] == 'pendiente' && !yaSeReprogramo);
    bool puedeSolicitarPropuesta = (cita['estado'] == 'confirmada' && !yaPropusoCambio);

    if (solicitudRecibida != null && !isHistorial) {
      DateTime nuevaFecha = DateTime.parse(solicitudRecibida['nueva_fecha']);
      String fechaFormateada = DateFormat('dd MMM yyyy', 'es_ES').format(nuevaFecha);
      String nuevaHora = solicitudRecibida['nueva_hora'].toString().substring(0, 5);
      String motivo = solicitudRecibida['motivo'] ?? 'Sin motivo';

      return Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MagicoonFilled.exclamationCircle, color: Colors.orange.shade800, size: 16),
                const SizedBox(width: 6),
                Text("¡Nueva Propuesta!", style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$fechaFormateada • $nuevaHora hrs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const Divider(height: 12),
                  Text('"$motivo"', style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _mostrarBottomSheetRechazo(context, cita['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red.shade700, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Rechazar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.responderPropuesta(cita['id'], 'aceptar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Aceptar", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (solicitudEnviada != null && !isHistorial) {
      return Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Esperando respuesta a tu propuesta...", 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildEstadoBadge(cita['estado']),
            if (isHistorial && ['cancelada', 'finalizada', 'rechazada', 'no asistida'].contains(cita['estado']))
              InkWell(
                onTap: () => _confirmarEliminacion(context, cita['id']),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: Colors.red.shade200), shape: BoxShape.circle),
                  child: Icon(MagicoonRegular.trash, color: Colors.red.shade400, size: 14),
                ),
              ),
          ],
        ),

        if (!isHistorial)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              children: [
                if (puedeReagendarDirecto) ...[
                  Expanded(child: _buildActionButton("Reagendar", MagicoonRegular.calendar, Colors.blue.shade700, Colors.blue.shade50, () => _mostrarModalReagendarLibre(context, cita))),
                  const SizedBox(width: 8),
                ],
                
                if (puedeSolicitarPropuesta) ...[
                  Expanded(child: _buildActionButton("Proponer Cambio", MagicoonRegular.clock, Colors.blue.shade700, Colors.blue.shade50, () => _mostrarBottomSheetPropuesta(context, cita))),
                  const SizedBox(width: 8),
                ],

                if (cita['estado'] == 'pendiente' || cita['estado'] == 'confirmada')
                  Expanded(child: _buildActionButton("Cancelar", MagicoonRegular.timesCircle, Colors.red.shade700, Colors.red.shade50, () => _confirmarCancelacion(context, cita['id']))),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildActionButton(String text, IconData icon, Color textColor, Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text, 
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    Color badgeColor = Colors.grey.shade200;
    Color textColor = Colors.grey.shade700;
    IconData icon = MagicoonFilled.infoCircle;
    if (estado == 'pendiente') {
      badgeColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = MagicoonFilled.clock;
    } else if (estado == 'confirmada') {
      badgeColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = MagicoonFilled.checkCircle;
    } else if (estado == 'cancelada' || estado == 'rechazada') {
      badgeColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = MagicoonFilled.timesCircle;
    } else if (estado == 'finalizada') {
      badgeColor = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      icon = MagicoonFilled.checkCircle;
    } else if (estado == 'no asistida') {
      badgeColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = MagicoonFilled.user;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Text(
            estado.toUpperCase(),
            style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
            child: Icon(MagicoonRegular.calendar, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text("No tienes citas registradas.", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Tus próximas consultas aparecerán aquí.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
  // ==========================================
  // FUNCIONES DE LOS MODALES DE PACIENTE
  // ==========================================
  void _confirmarCancelacion(BuildContext context, int citaId) {
    Get.defaultDialog(
      title: "Cancelar Cita",
      middleText: "¿Estás seguro que deseas cancelar esta cita? Esta acción no se puede deshacer.",
      textConfirm: "Sí, cancelar",
      textCancel: "Cerrar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: MiTema.azulOscuro,
      onConfirm: () {
        Get.back();
        controller.cancelarCita(citaId);
      },
    );
  }
  void _confirmarEliminacion(BuildContext context, int citaId) {
    Get.defaultDialog(
      title: "Ocultar Cita",
      middleText: "¿Deseas eliminar este registro de tu historial?",
      textConfirm: "Eliminar",
      textCancel: "Cancelar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.eliminarCita(citaId);
      },
    );
  }
  void _mostrarBottomSheetRechazo(BuildContext context, int citaId) {
    final TextEditingController motivoCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rechazar Cambio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Por favor, indica brevemente por qué no puedes aceptar el nuevo horario:", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 15),
            TextField(
              controller: motivoCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe el motivo...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                onPressed: () {
                  if (motivoCtrl.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Debes escribir un motivo', backgroundColor: Colors.red.shade100);
                    return;
                  }
                  controller.responderPropuesta(citaId, 'rechazar', motivo: motivoCtrl.text.trim());
                },
                child: const Text("Confirmar Rechazo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarBottomSheetPropuesta(BuildContext context, Map<String, dynamic> cita) {
    final Rxn<DateTime> selectedDate = Rxn<DateTime>();
    final RxnString selectedSlot = RxnString();
    final TextEditingController motivoCtrl = TextEditingController();
    controller.availableSlots.clear();
    controller.slotMessage("Elige una fecha para ver horarios disponibles");
    int doctorId = cita['doctor_id'] ?? cita['doctor']['id'];
    
    Get.bottomSheet(
      // 👇 1. Agregamos SingleChildScrollView
      SingleChildScrollView(
        child: Container(
          // 👇 2. Cambiamos EdgeInsets.all(25) por EdgeInsets.only(...) sumando el teclado
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: 25 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(MagicoonRegular.calendar, color: MiTema.azulOscuro),
                    const SizedBox(width: 10),
                    const Text("Proponer Nuevo Horario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 25),
                const Text("1. Selecciona la nueva fecha", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      builder: (context, child) {
                        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: MiTema.azulOscuro)), child: child!);
                      },
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                      selectedSlot.value = null;
                      String fechaFormateada = DateFormat('yyyy-MM-dd').format(picked);
                      controller.fetchDisponibilidad(doctorId, fechaFormateada);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate.value != null ? DateFormat('dd / MM / yyyy').format(selectedDate.value!) : "dd / mm / aaaa",
                          style: TextStyle(color: selectedDate.value != null ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const Icon(MagicoonRegular.calendar, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("2. Horarios disponibles", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                  child: controller.isFetchingSlots.value
                      ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
                      : controller.availableSlots.isEmpty
                      ? Text(controller.slotMessage.value, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.center)
                      : Wrap(
                          spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                          children: controller.availableSlots.map((hora) {
                            bool isSelected = selectedSlot.value == hora;
                            return ChoiceChip(
                              label: Text(hora, style: TextStyle(color: isSelected ? Colors.white : MiTema.azulOscuro, fontWeight: FontWeight.bold)),
                              selected: isSelected,
                              selectedColor: MiTema.azulOscuro,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: MiTema.azulOscuro)),
                              onSelected: (bool selected) { if (selected) selectedSlot.value = hora; },
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),
                const Text("Motivo del cambio", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: motivoCtrl,
                  decoration: InputDecoration(hintText: "Ej. Me surgió un contratiempo...", filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), disabledBackgroundColor: Colors.grey.shade300),
                    onPressed: (selectedDate.value != null && selectedSlot.value != null)
                        ? () {
                            if (motivoCtrl.text.trim().isEmpty) {
                              Get.snackbar('Atención', 'Por favor, escribe un motivo.', backgroundColor: Colors.orange.shade100);
                              return;
                            }
                            String fechaFormat = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
                            controller.proponerCambio(cita['id'], fechaFormat, selectedSlot.value!, motivoCtrl.text.trim());
                          }
                        : null,
                    child: const Text("Enviar Propuesta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true, // Esto ya lo tenías, es clave para que el teclado funcione
    );
  }
  
  void _mostrarModalReagendarLibre(BuildContext context, Map<String, dynamic> cita) {
    final Rxn<DateTime> selectedDate = Rxn<DateTime>();
    final RxnString selectedSlot = RxnString();
    controller.availableSlots.clear();
    controller.slotMessage("Elige una fecha para ver horarios disponibles");
    int doctorId = cita['doctor_id'] ?? cita['doctor']['id'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(MagicoonFilled.calendar, color: MiTema.azulOscuro),
                  const SizedBox(width: 10),
                  const Text("Reagendar Cita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              const Text("Recuerda que solo puedes reagendar de forma directa una sola vez.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 25),
              const Text("1. Selecciona la nueva fecha", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) {
                      return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: MiTema.azulOscuro)), child: child!);
                    },
                  );
                  if (picked != null) {
                    selectedDate.value = picked;
                    selectedSlot.value = null;
                    String fechaFormateada = DateFormat('yyyy-MM-dd').format(picked);
                    controller.fetchDisponibilidad(doctorId, fechaFormateada);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate.value != null ? DateFormat('dd / MM / yyyy').format(selectedDate.value!) : "dd / mm / aaaa",
                        style: TextStyle(color: selectedDate.value != null ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const Icon(MagicoonRegular.calendar, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("2. Horarios disponibles", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                child: controller.isFetchingSlots.value
                    ? Center(child: CircularProgressIndicator(color: MiTema.azulOscuro))
                    : controller.availableSlots.isEmpty
                    ? Text(controller.slotMessage.value, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.center)
                    : Wrap(
                        spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                        children: controller.availableSlots.map((hora) {
                          bool isSelected = selectedSlot.value == hora;
                          return ChoiceChip(
                            label: Text(hora, style: TextStyle(color: isSelected ? Colors.white : MiTema.azulOscuro, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            selectedColor: MiTema.azulOscuro,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: MiTema.azulOscuro)),
                            onSelected: (bool selected) { if (selected) selectedSlot.value = hora; },
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: MiTema.azulOscuro, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), disabledBackgroundColor: Colors.grey.shade300),
                  onPressed: (selectedDate.value != null && selectedSlot.value != null)
                      ? () {
                          String fechaFormat = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
                          controller.reagendarLibre(cita['id'], fechaFormat, selectedSlot.value!);
                        }
                      : null,
                  child: const Text("Confirmar Nuevo Horario", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}