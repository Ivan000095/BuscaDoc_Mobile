import 'package:buscadoc_mobile/theme/tema.dart';
import 'package:flutter/material.dart';
import 'package:buscadoc_mobile/services/comment_service.dart';
import 'package:buscadoc_mobile/utils/global.dart';

class RepliesView extends StatefulWidget {
  final int commentId;
  final Map<String, dynamic> comment;

  const RepliesView({
    super.key,
    required this.commentId,
    required this.comment,
  });

  @override
  State<RepliesView> createState() => _RepliesViewState();
}

class _RepliesViewState extends State<RepliesView> {
  final _commentService = CommentService();
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> replies = [];
  bool loading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final result = await _commentService.getReplies(commentId: widget.commentId);
      if (!mounted) return;
      
      setState(() {
        replies = result['success'] == true ? result['data'] ?? [] : [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar respuestas'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> _submitReply() async {
    if (_controller.text.trim().isEmpty || !mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _commentService.createReply(
        commentId: widget.commentId,
        contenido: _controller.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        _controller.clear();
        FocusScope.of(context).unfocus();
        await _loadReplies();
        _showSuccess('Respuesta publicada correctamente');
      } else {
        _showError(result['message'] ?? 'Error al responder');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError('Error de conexión al enviar');
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final autor = widget.comment['autor'] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Respuestas', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: autor['foto'] != null
                          ? NetworkImage('${Globals.webUrl}/storage/${autor['foto']}')
                          : null,
                      child: autor['foto'] == null ? const Icon(Icons.person, color: Colors.grey, size: 22) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            autor['name'] ?? 'Usuario',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            _formatDate(widget.comment['created_at'] ?? ''),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.comment['contenido'] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : replies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no hay respuestas',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sé el primero en responder',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final reply = replies[index];
                          final respondedor = reply['respondedor'] ?? {};
                          return _buildReplyCard(respondedor, reply);
                        },
                      ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Escribe una respuesta...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 1,
                    onSubmitted: (_) => _submitReply(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: MiTema.azulOscuro,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _submitReply,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(Map<String, dynamic> respondedor, Map<String, dynamic> reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: respondedor['foto'] != null
                    ? NetworkImage('${Globals.webUrl}/storage/${respondedor['foto']}')
                    : null,
                child: respondedor['foto'] == null ? const Icon(Icons.person, color: Colors.grey, size: 16) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      respondedor['name'] ?? 'Usuario',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${respondedor['role'] ?? ''} • ${_formatDate(reply['created_at'])}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reply['contenido'] ?? '',
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}