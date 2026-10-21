import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../errors/failures.dart';
import '../services/storage_service.dart';

class ApiClient {
  final http.Client _client;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final fullUrl = '${ApiConfig.baseUrl}/$cleanEndpoint';

    if (queryParameters == null || queryParameters.isEmpty) {
      return Uri.parse(fullUrl);
    }

    // Convert values to string and remove nulls
    final cleanParams = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        cleanParams[key] = value.toString();
      }
    });

    return Uri.parse(fullUrl).replace(queryParameters: cleanParams);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      if (kDebugMode) print('🌐 [GET] $uri');

      final response = await _client.get(uri, headers: headers).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('La solicitud tardó demasiado tiempo en responder.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado al conectar con el servidor: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final jsonBody = body != null ? jsonEncode(body) : null;
      if (kDebugMode) print('🌐 [POST] $uri\nBody: $jsonBody');

      final response = await _client
          .post(uri, headers: headers, body: jsonBody)
          .timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('La solicitud tardó demasiado tiempo en responder.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado al conectar con el servidor: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print('📥 [RESP ${response.statusCode}] ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        return response.body;
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Tu sesión ha expirado o no tienes autorización.');
    } else if (response.statusCode == 400) {
      String message = 'Solicitud incorrecta.';
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('detail')) {
            message = decoded['detail'].toString();
          } else if (decoded.containsKey('title')) {
            message = decoded['title'].toString();
          } else if (decoded.containsKey('errors')) {
            final errors = decoded['errors'] as Map<String, dynamic>;
            final errorList = <String>[];
            errors.forEach((_, val) {
              if (val is List) {
                errorList.addAll(val.map((e) => e.toString()));
              } else {
                errorList.add(val.toString());
              }
            });
            message = errorList.join('\n');
          } else if (decoded.containsKey('message')) {
            message = decoded['message'].toString();
          }
        } else if (decoded is String) {
          message = decoded;
        }
      } catch (_) {
        if (response.body.isNotEmpty) message = response.body;
      }
      throw ValidationException(message);
    } else if (response.statusCode == 404) {
      throw ServerException('El recurso solicitado no fue encontrado.', 404);
    } else {
      throw ServerException('El servidor respondió con error (${response.statusCode}).', response.statusCode);
    }
  }
}
