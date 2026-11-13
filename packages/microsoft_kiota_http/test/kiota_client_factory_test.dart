import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:microsoft_kiota_http/microsoft_kiota_http.dart';
import 'package:test/test.dart';

/// A local server that answers each request with the next queued status
/// code, then 200, and records the method and path of every request. When a
/// redirect status is set, requests to /send are first redirected to
/// /redirected with it.
class _TestServer {
  _TestServer._(this._server, this._statusCodes, this._redirectStatus) {
    _server.listen(_handle);
  }

  static Future<_TestServer> start(
    List<int> statusCodes, {
    int? redirectStatus,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return _TestServer._(server, List.of(statusCodes), redirectStatus);
  }

  final HttpServer _server;
  final List<int> _statusCodes;
  final int? _redirectStatus;
  final List<String> requests = [];

  Uri get sendUri =>
      Uri.parse('http://${_server.address.host}:${_server.port}/send');

  Future<void> _handle(HttpRequest request) async {
    requests.add('${request.method} ${request.uri.path}');
    await request.drain<void>();
    final redirectStatus = _redirectStatus;
    if (redirectStatus != null && request.uri.path == '/send') {
      request.response
        ..statusCode = redirectStatus
        ..headers.set(HttpHeaders.locationHeader, '/redirected');
    } else {
      request.response.statusCode = _statusCodes.isEmpty
          ? 200
          : _statusCodes.removeAt(0);
    }
    await request.response.close();
  }

  Future<void> close() => _server.close(force: true);
}

Future<(int, List<String>)> _send(
  String method,
  List<int> statusCodes, {
  bool? retryUnprocessedMutationsOnly,
  int? redirectStatus,
}) async {
  final server = await _TestServer.start(
    statusCodes,
    redirectStatus: redirectStatus,
  );
  // Leave the argument out unless a test sets it, so the default is what's tested.
  final client = retryUnprocessedMutationsOnly == null
      ? KiotaClientFactory.createClient()
      : KiotaClientFactory.createClient(
          retryUnprocessedMutationsOnly: retryUnprocessedMutationsOnly,
        );
  try {
    final request = http.Request(method, server.sendUri);
    if (method.toUpperCase() != 'GET' && method.toUpperCase() != 'DELETE') {
      request.body = '{"message":"hello"}';
    }
    final response = await client.send(request);
    await response.stream.drain<void>();
    return (response.statusCode, server.requests);
  } finally {
    client.close();
    await server.close();
  }
}

void main() {
  group('KiotaClientFactory retryUnprocessedMutationsOnly', () {
    for (final method in ['POST', 'PATCH']) {
      test('retries $method on 504 by default', () async {
        final (status, requests) = await _send(method, [504]);
        expect(status, equals(200));
        expect(requests, hasLength(2));
      });
    }

    for (final method in ['POST', 'PATCH', 'post']) {
      for (final statusCode in [408, 500, 502, 504]) {
        test('does not retry $method on $statusCode when enabled', () async {
          final (status, requests) = await _send(method, [
            statusCode,
          ], retryUnprocessedMutationsOnly: true);
          expect(status, equals(statusCode));
          expect(requests, hasLength(1));
        });
      }
    }

    for (final method in ['POST', 'PATCH']) {
      for (final statusCode in [429, 503]) {
        test('retries $method on $statusCode when enabled', () async {
          final (status, requests) = await _send(method, [
            statusCode,
          ], retryUnprocessedMutationsOnly: true);
          expect(status, equals(200));
          expect(requests, hasLength(2));
        });
      }
    }

    for (final method in ['GET', 'PUT', 'DELETE', 'QUERY']) {
      test('retries $method on 504 when enabled', () async {
        final (status, requests) = await _send(method, [
          504,
        ], retryUnprocessedMutationsOnly: true);
        expect(status, equals(200));
        expect(requests, hasLength(2));
      });
    }

    test('stops retrying POST when a later response leaves the outcome '
        'unknown', () async {
      final (status, requests) = await _send('POST', [
        503,
        504,
      ], retryUnprocessedMutationsOnly: true);
      expect(status, equals(504));
      expect(requests, hasLength(2));
    });

    test(
      'resends the original POST after a redirect to GET by default',
      () async {
        final (status, requests) = await _send('POST', [
          504,
        ], redirectStatus: 303);
        expect(status, equals(200));
        expect(
          requests,
          equals([
            'POST /send',
            'GET /redirected',
            'POST /send',
            'GET /redirected',
          ]),
        );
      },
    );

    test('does not resend the original POST after a redirect to GET when '
        'enabled', () async {
      final (status, requests) = await _send(
        'POST',
        [504],
        retryUnprocessedMutationsOnly: true,
        redirectStatus: 303,
      );
      expect(status, equals(504));
      expect(requests, equals(['POST /send', 'GET /redirected']));
    });

    test('does not resend the original POST when the redirected GET gets a '
        '503', () async {
      // The 303 shows the server accepted the POST; the 503 only describes
      // the redirected GET.
      final (status, requests) = await _send(
        'POST',
        [503],
        retryUnprocessedMutationsOnly: true,
        redirectStatus: 303,
      );
      expect(status, equals(503));
      expect(requests, equals(['POST /send', 'GET /redirected']));
    });
  });
}
