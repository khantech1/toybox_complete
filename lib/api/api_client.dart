import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/shared_prefs.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await SharedPrefs.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Uri _uri(String endpoint, [Map<String, String>? params]) {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return params != null ? uri.replace(queryParameters: params) : uri;
  }

  static dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final msg = body['message'] ?? body['error'] ?? 'Request failed';
    throw ApiException(msg.toString(), statusCode: res.statusCode);
  }

  // ── GET ────────────────────────────────────────────────────────────────────
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? params,
    bool auth = true,
  }) async {
    try {
      final res = await http
          .get(_uri(endpoint, params), headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw const ApiException('No internet connection');
    } on HttpException {
      throw const ApiException('HTTP error occurred');
    }
  }

  // ── POST ───────────────────────────────────────────────────────────────────
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final res = await http
          .post(
            _uri(endpoint),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }

  // ── PUT ────────────────────────────────────────────────────────────────────
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final res = await http
          .put(
            _uri(endpoint),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  static Future<dynamic> delete(String endpoint, {bool auth = true}) async {
    try {
      final res = await http
          .delete(_uri(endpoint), headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }

  // ── Multipart upload ───────────────────────────────────────────────────────
  static Future<dynamic> uploadFile(
    String endpoint,
    String fieldName,
    File file,
    Map<String, String> fields,
  ) async {
    try {
      final token = await SharedPrefs.getToken();
      final req = http.MultipartRequest('POST', _uri(endpoint));
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.fields.addAll(fields);
      req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      return _parse(res);
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }
}
