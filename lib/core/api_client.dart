import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/api_log.dart';
import 'package:pulse/core/env.dart';
import 'package:pulse/core/failure.dart';


final apiClientProvider = Provider<ApiClient>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return ApiClient(client: client, baseUrl: '${Env.apiBase}/api/${Env.bucket}');
});


class ApiClient {
  ApiClient({required this.client, required this.baseUrl});

  final http.Client client;
  final String baseUrl;

  Future<Object?> get(String path) {
    final uri = _uri(path);
    return _send('GET', uri, client.get(uri));
  }

  Future<Object?> post(String path, Map<String, dynamic> body) {
    final uri = _uri(path);
    return _send(
      'POST',
      uri,
      client.post(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<void> delete(String path) async {
    final uri = _uri(path);
    await _send('DELETE', uri, client.delete(uri));
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Object?> _send(
    String method,
    Uri uri,
    Future<http.Response> request,
  ) async {
    final stopwatch = Stopwatch()..start();
    apiLog('$method $uri');

    final http.Response response;
    try {
      response = await request;
    } on http.ClientException catch (error) {
      apiLog('$method $uri failed: ${error.message}');
      throw const NetworkFailure();
    }

    final status = response.statusCode;
    apiLog('$method $uri -> $status (${stopwatch.elapsedMilliseconds} ms)');
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
