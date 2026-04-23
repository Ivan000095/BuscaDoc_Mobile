import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/services/comment_service.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:get/get.dart';
import 'package:buscadoc_mobile/utils/ui.dart';
import 'package:magicoon_icons/magicoon.dart';

class CommentDialog extends StatefulWidget {
  final int destinatarioId;
  final VoidCallback onCommentAdded;

  const CommentDialog({
    super.key,
    required this.destinatarioId,
    required this.onCommentAdded,
  });

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentService = CommentService();
  int _rating = 5;
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = await Usuario.obtenerToken();
    if (token == null) {
      Get.snackbar('Error', 'Debes iniciar sesión para dejar una reseña');
      return;
    }

    setState(() => _loading = true);
    final result = await _commentService.createReview(
      doctorId: widget.destinatarioId,
      rating: _rating,
      contenido: _controller.text,
    );

    setState(() => _loading = false);

    if (result['success'] == true) {
      Navigator.pop(context);
      widget.onCommentAdded();
      UIUtils.showRoundedSnackBar(context, "¡Su reseña se publicó correctamente!", MiTema.verde, MiTema.blanco);
    } else {
      if (result['requires_cita'] == true || result['error_code'] == 'CITA_REQUERIDA') {
        Get.snackbar(
          'Cita requerida',
          'Solo puedes reseñar a doctores con los que hayas tenido una cita finalizada',
          backgroundColor: MiTema.azulOscuro,
          colorText: MiTema.blanco,
          icon: const Icon(Icons.event_available, color: Colors.orange),
          duration: const Duration(seconds: 6),
          mainButton: TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Agendar cita',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
        );
      } else if (result['error_code'] == 401) {
        Get.snackbar(
          'Sesión requerida 🔐',
          'Inicia sesión para poder dejar una reseña',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade900,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Error ❌',
          result['message'] ?? 'No se pudo publicar tu reseña',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- CABECERA ICONO Y TÍTULO ---
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MiTema.azulOscuro.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(MagicoonFilled.star, color: MiTema.azulOscuro, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dejar Reseña',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MiTema.azulOscuro,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuéntanos tu experiencia con este doctor',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => _rating = index + 1),
                      iconSize: 42, // Tamaño grande para que se vea igual
                      splashRadius: 28, // Efecto de onda al presionar
                      padding: const EdgeInsets.symmetric(horizontal: 2), // Separación limpia
                      constraints: const BoxConstraints(), // Evita márgenes nativos excesivos
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          index < _rating ? MagicoonFilled.star : MagicoonRegular.star,
                          key: ValueKey<bool>(index < _rating),
                          color: Colors.amber,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_rating de 5 estrellas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),

                // --- INPUT DE TEXTO ---
                TextFormField(
                  controller: _controller,
                  maxLines: 4,
                  maxLength: 500,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ej: Muy buena atención, puntual, profesional...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF5F7F9), // Fondo gris suave moderno
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: MiTema.azulOscuro, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.red.shade300, width: 1),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    // 👇 LA MAGIA PARA QUE NO HAYA OVERFLOW EN EL ERROR
                    errorMaxLines: 3, 
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor escribe tu opinión';
                    }
                    if (value.trim().length < 10) {
                      return 'La reseña debe tener al menos 10 caracteres para ser válida.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- BOTONES CANCELAR Y PUBLICAR ---
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MiTema.azulOscuro,
                          foregroundColor: MiTema.blanco,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _loading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: MiTema.blanco),
                              )
                            : const Text(
                                'Publicar',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}