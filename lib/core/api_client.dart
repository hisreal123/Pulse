import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pulse/core/failure.dart';

class ApiClient {
  ApiClient({required this.client, required this.baseUrl});

  final http.Client client;
  final String baseUrl;

  Future<Object?> get(String path) {
    return _send(client.get(_uri(path)));
  }

  Future<Object?> post(String path, Map<String, dynamic> body) {
    return _send(
      client.post(
        _uri(path),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<void> delete(String path) async {
    await _send(client.delete(_uri(path)));
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Object?> _send(Future<http.Response> request) async {
    final http.Response response;
    try {
      response = await request;
    } on http.ClientException {
      throw const NetworkFailure();
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    }

    throw switch (status) {
      400 => ValidationFailure(_errorMessage(response.body)),
      404 => const NotFoundFailure(),
      _ => const ServerFailure(),
    };
  }

  String _errorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['error'] as String;
    } catch (_) {
      return 'Invalid request';
    }
  }
}
