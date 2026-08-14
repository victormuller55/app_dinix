import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';

const int _maxRateLimitRetries = 1;
const int _maxRetryAfterSeconds = 60;
const int _maxLoggedBodyChars = 4000;

void _logHttp(String message) {
  if (!kDebugMode) return;
  developer.log(message, name: 'HTTP');
}

String _formatBody(Object? body) {
  if (body == null) return '(sem body)';
  final text = body is String ? body : jsonEncode(body);
  if (text.length <= _maxLoggedBodyChars) return text;
  return '${text.substring(0, _maxLoggedBodyChars)}... (${text.length} chars)';
}

String _formatResponseBody(http.Response response, {bool binary = false}) {
  if (binary) return '(binary ${response.bodyBytes.length} bytes)';
  final contentType = response.headers['content-type'] ?? '';
  if (contentType.contains('octet-stream') || contentType.contains('image/')) {
    return '(binary ${response.bodyBytes.length} bytes)';
  }
  return _formatBody(utf8.decode(response.bodyBytes));
}

Future<http.Response> _request({
  required String method,
  required Uri uri,
  Object? body,
  bool binaryResponse = false,
  Duration? timeout,
  required Future<http.Response> Function() call,
}) async {
  Future<http.Response> run() {
    final future = call();
    if (timeout == null) return future;
    return future.timeout(timeout);
  }

  try {
    var response = await run();
    var retries = 0;

    while (response.statusCode == 429 && retries < _maxRateLimitRetries) {
      final retryAfter = int.tryParse(response.headers['retry-after'] ?? '') ?? 1;
      final waitSeconds = retryAfter.clamp(1, _maxRetryAfterSeconds);
      await Future.delayed(Duration(seconds: waitSeconds));
      response = await run();
      retries++;
    }

    final requestBody = body == null ? '' : '\nBody: ${_formatBody(body)}';
    _logHttp(
      '$method $uri [${response.statusCode}]$requestBody\n'
      'Response: ${_formatResponseBody(response, binary: binaryResponse)}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw ApiException(
      AppResponse(statusCode: response.statusCode, body: response.body),
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    final requestBody = body == null ? '' : '\nBody: ${_formatBody(body)}';
    _logHttp('✗ $method $uri$requestBody\nError: $e');
    throw ApiException(AppResponse(statusCode: 0, body: e.toString()));
  }
}

Future<Map<String, String>> _jsonHeaders() async {
  return {
    'Content-Type': 'application/json; charset=UTF-8',
    ...await getAuthHeaders(),
  };
}

Future<AppResponse> postJson({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? parameters,
}) async {
  final headers = await _jsonHeaders();
  final uri = Uri.parse(endpoint + _query(parameters));
  final encodedBody = jsonEncode(body);
  final response = await _request(
    method: 'POST',
    uri: uri,
    body: encodedBody,
    call: () => http.post(uri, headers: headers, body: encodedBody),
  );
  return AppResponse(statusCode: response.statusCode, body: utf8.decode(response.bodyBytes));
}

Future<AppResponse> putJson({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? parameters,
}) async {
  final headers = await _jsonHeaders();
  final uri = Uri.parse(endpoint + _query(parameters));
  final encodedBody = jsonEncode(body);
  final response = await _request(
    method: 'PUT',
    uri: uri,
    body: encodedBody,
    call: () => http.put(uri, headers: headers, body: encodedBody),
  );
  return AppResponse(statusCode: response.statusCode, body: utf8.decode(response.bodyBytes));
}

Future<AppResponse> getJson({
  required String endpoint,
  Map<String, String>? parameters,
  Duration? timeout,
}) async {
  final headers = await _jsonHeaders();
  final uri = Uri.parse(endpoint + _query(parameters));
  final response = await _request(
    method: 'GET',
    uri: uri,
    timeout: timeout,
    call: () => http.get(uri, headers: headers),
  );
  return AppResponse(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
  );
}

Future<Uint8List> getBytes({
  required String endpoint,
  Map<String, String>? parameters,
}) async {
  final headers = await getAuthHeaders();
  final uri = Uri.parse(endpoint + _query(parameters));
  final response = await _request(
    method: 'GET',
    uri: uri,
    binaryResponse: true,
    call: () => http.get(uri, headers: headers),
  );
  return response.bodyBytes;
}

Future<AppResponse> patchJson({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? parameters,
}) async {
  final headers = await _jsonHeaders();
  final uri = Uri.parse(endpoint + _query(parameters));
  final encodedBody = jsonEncode(body);
  final response = await _request(
    method: 'PATCH',
    uri: uri,
    body: encodedBody,
    call: () => http.patch(uri, headers: headers, body: encodedBody),
  );
  return AppResponse(statusCode: response.statusCode, body: utf8.decode(response.bodyBytes));
}

Future<void> deleteJson({
  required String endpoint,
  Map<String, String>? parameters,
}) async {
  final headers = await _jsonHeaders();
  final uri = Uri.parse(endpoint + _query(parameters));
  await _request(
    method: 'DELETE',
    uri: uri,
    call: () => http.delete(uri, headers: headers),
  );
}

Future<AppResponse> postMultipart({
  required String endpoint,
  required Map<String, dynamic> dados,
  XFile? foto,
  Map<String, String>? parameters,
}) async {
  return _sendMultipart(
    method: 'POST',
    endpoint: endpoint,
    dados: dados,
    foto: foto,
    parameters: parameters,
  );
}

Future<AppResponse> putMultipart({
  required String endpoint,
  required Map<String, dynamic> dados,
  XFile? foto,
  Map<String, String>? parameters,
}) async {
  return _sendMultipart(
    method: 'PUT',
    endpoint: endpoint,
    dados: dados,
    foto: foto,
    parameters: parameters,
  );
}

Future<AppResponse> postMultipartFiles({
  required String endpoint,
  required String fieldName,
  required List<XFile> files,
  Map<String, String>? parameters,
}) async {
  if (files.isEmpty) {
    throw ArgumentError('Informe ao menos um arquivo para upload');
  }

  final uri = Uri.parse(endpoint + _query(parameters));
  final authHeaders = await getAuthHeaders();

  Future<http.Response> send() async {
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(authHeaders);

    for (final file in files) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: file.name,
          contentType: _mediaTypeFromName(file.name),
        ),
      );
    }

    return request.send().then(http.Response.fromStream);
  }

  final response = await _request(
    method: 'POST',
    uri: uri,
    body: {
      'field': fieldName,
      'files': files.map((f) => f.name).toList(),
    },
    call: send,
  );
  return AppResponse(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
  );
}

Future<AppResponse> _sendMultipart({
  required String method,
  required String endpoint,
  required Map<String, dynamic> dados,
  XFile? foto,
  Map<String, String>? parameters,
}) async {
  final uri = Uri.parse(endpoint + _query(parameters));
  final authHeaders = await getAuthHeaders();
  final fotoBytes = foto != null ? await foto.readAsBytes() : null;

  Future<http.Response> send() async {
    final request = http.MultipartRequest(method, uri);
    request.headers.addAll(authHeaders);

    request.files.add(
      http.MultipartFile.fromString(
        'dados',
        jsonEncode(dados),
        contentType: MediaType('application', 'json'),
      ),
    );

    if (foto != null && fotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: foto.name,
          contentType: _mediaTypeFromName(foto.name),
        ),
      );
    }

    return request.send().then(http.Response.fromStream);
  }

  final response = await _request(
    method: method,
    uri: uri,
    body: {
      'dados': dados,
      if (foto != null) 'foto': foto.name,
    },
    call: send,
  );
  return AppResponse(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
  );
}

MediaType? _mediaTypeFromName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return MediaType('image', 'png');
  if (lower.endsWith('.webp')) return MediaType('image', 'webp');
  if (lower.endsWith('.gif')) return MediaType('image', 'gif');
  return MediaType('image', 'jpeg');
}

String _query(Map<String, String>? parameters) {
  if (parameters == null || parameters.isEmpty) return '';
  return '?${parameters.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
}

ErrorModel parseApiError(Object e) => errorModelFromException(e);
