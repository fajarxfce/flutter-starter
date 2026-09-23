import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Deterministic in-process HTTP backend; never contacts the network.
final class DemoAdapter implements HttpClientAdapter {
  DemoAdapter({this.latency = const Duration(milliseconds: 350)});
  final Duration latency;
  bool expireSession = false;
  static const user = <String, Object>{
    'id': 'demo-user',
    'email': 'demo@example.com',
    'display_name': 'Alex Morgan',
  };
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(latency);
    ResponseBody reply(int status, Object data) => ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
    if (options.path == '/auth/login' && options.method == 'POST') {
      final raw = options.data;
      final data =
          (raw is String ? jsonDecode(raw) : raw) as Map<String, dynamic>;
      if (data['email'] == 'timeout@example.com') {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      }
      if (data['email'] == 'server@example.com') {
        return reply(503, {'message': 'Unavailable'});
      }
      if (data['email'] != 'demo@example.com' ||
          data['password'] != 'Demo123!') {
        return reply(401, {'message': 'Invalid credentials'});
      }
      expireSession = false;
      return reply(200, {'access_token': 'demo-access-token', 'user': user});
    }
    if (options.path == '/auth/me' && options.method == 'GET') {
      if (expireSession ||
          options.headers['Authorization'] != 'Bearer demo-access-token') {
        return reply(401, {'message': 'Session expired'});
      }
      return reply(200, user);
    }
    return reply(404, {'message': 'Not found'});
  }

  @override
  void close({bool force = false}) {}
}
