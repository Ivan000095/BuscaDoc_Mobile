import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buscadoc_mobile/utils/global.dart';
import 'package:buscadoc_mobile/model/usuario.dart';

class CommentService {
  final String baseUrl = Globals.webUrl;

  Future<String?> _getToken() async {
    return await Usuario.obtenerToken();
  }

  Future<Map<String, dynamic>> createReview({
    required int doctorId,
    required int rating,
    required String contenido,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/comments');
      final token = await _getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Debes iniciar sesión para reseñar',
          'error_code': 401,
        };
      }

      final body = {
        'destinatario_id': doctorId.toString(),
        'tipo': 'resena',
        'rating': rating.toString(),
        'contenido': contenido,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);

        if (response.statusCode == 403 && error['error_code'] == 'CITA_REQUERIDA') {
          return {
            'success': false,
            'message': error['message'],
            'error_code': 403,
            'requires_cita': true,
          };
        }
        
        return {
          'success': false,
          'message': error['message'] ?? 'Error al publicar reseña',
          'error_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error createReview: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getComments({
    required int userId,
    String? tipo,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      String url = '$baseUrl/api/users/$userId/comments?page=$page&per_page=$perPage';
      if (tipo != null && ['resena', 'pregunta'].contains(tipo)) {
        url += '&tipo=$tipo';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar comentarios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getComments: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getReviews({
    required int doctorUserId,
    int page = 1,
    int perPage = 10,
  }) async {
    return getComments(
      userId: doctorUserId,
      tipo: 'resena',
      page: page,
      perPage: perPage,
    );
  }

  Future<Map<String, dynamic>> getQuestions({
    required int doctorUserId,
    int page = 1,
    int perPage = 10,
  }) async {
    return getComments(
      userId: doctorUserId,
      tipo: 'pregunta',
      page: page,
      perPage: perPage,
    );
  }

  Future<Map<String, dynamic>> createReply({
    required int commentId,
    required String contenido,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/comments/$commentId/reply');
      final token = await _getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Debes iniciar sesión para responder',
          'error_code': 401,
        };
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'contenido': contenido}),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al responder',
          'error_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error createReply: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getReplies({
    required int commentId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/comments/$commentId/replies');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar respuestas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getReplies: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> canUserReview({
    required int doctorUserId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/api/users/$doctorUserId/can-review');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true && data['can_review'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Error canUserReview: $e');
      return false;
    }
  }
}