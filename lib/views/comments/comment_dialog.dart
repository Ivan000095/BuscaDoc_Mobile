import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/services/comment_service.dart';
import 'package:buscadoc_mobile/model/usuario.dart';
import 'package:get/get.dart';

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
      Get.snackbar(
        'Éxito ✨',
        result['message'] ?? 'Tu reseña se publicó correctamente',
        backgroundColor: MiTema.azulOscuro,
        colorText: MiTema.blanco,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
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
      } 
      else if (result['error_code'] == 401) {
        Get.snackbar(
          'Sesión requerida 🔐',
          'Inicia sesión para poder dejar una reseña',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade900,
          duration: const Duration(seconds: 4),
        );
      } 
      else {
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.star, color: MiTema.azulOscuro, size: 24),
          const SizedBox(width: 8),
          const Text('Dejar Reseña'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuéntanos tu experiencia con este doctor',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              const Text('Tu calificación:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => _rating = index + 1);
                    },
                  );
                }),
              ),
              Text(
                '$_rating de 5 estrellas',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Tu opinión',
                  hintText: 'Ej: Muy buena atención, puntual, profesional...',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor escribe tu opinión';
                  }
                  if (value.trim().length < 10) {
                    return 'La reseña debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Text(
                '${_controller.text.length}/500',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: MiTema.azulOscuro,
            foregroundColor: MiTema.blanco,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: MiTema.blanco),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send, size: 18),
                    SizedBox(width: 4),
                    Text('Publicar'),
                  ],
                ),
        ),
      ],
    );
  }
}