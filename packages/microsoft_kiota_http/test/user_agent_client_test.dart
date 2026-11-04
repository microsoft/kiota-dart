import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:microsoft_kiota_http/microsoft_kiota_http.dart';
import 'package:test/test.dart';

void main() {
  group('UserAgentClient', () {
    test('sets User-Agent header when not present', () async {
      late http.BaseRequest capturedRequest;
      final inner = MockClient((request) async {
        capturedRequest = request;
        return http.Response('ok', 200);
      });

      final client = UserAgentClient(inner, userAgent: 'kiota-dart/1.0.0');
      final request = http.Request('GET', Uri.parse('https://example.test'));

      await client.send(request);

      expect(capturedRequest.headers['User-Agent'], equals('kiota-dart/1.0.0'));
    });

    test(
      'preserves existing User-Agent and appends kiota user agent',
      () async {
        late http.BaseRequest capturedRequest;
        final inner = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        });

        final client = UserAgentClient(inner, userAgent: 'kiota-dart/1.0.0');
        final request = http.Request('GET', Uri.parse('https://example.test'));
        request.headers['User-Agent'] = 'my-custom-client/2.5.0';

        await client.send(request);

        expect(
          capturedRequest.headers['User-Agent'],
          equals('my-custom-client/2.5.0 kiota-dart/1.0.0'),
        );
      },
    );

    test(
      'preserves existing lowercase user-agent header and appends without duplicating keys',
      () async {
        late http.BaseRequest capturedRequest;
        final inner = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        });

        final client = UserAgentClient(inner, userAgent: 'kiota-dart/1.0.0');
        final request = http.Request('GET', Uri.parse('https://example.test'));
        request.headers['user-agent'] = 'existing-agent/1.0';

        await client.send(request);

        expect(
          capturedRequest.headers['user-agent'],
          equals('existing-agent/1.0 kiota-dart/1.0.0'),
        );
        expect(
          capturedRequest.headers.keys
              .where((k) => k.toLowerCase() == 'user-agent')
              .length,
          equals(1),
        );
      },
    );

    test('does not duplicate user agent if already present', () async {
      late http.BaseRequest capturedRequest;
      final inner = MockClient((request) async {
        capturedRequest = request;
        return http.Response('ok', 200);
      });

      final client = UserAgentClient(inner, userAgent: 'kiota-dart/1.0.0');
      final request = http.Request('GET', Uri.parse('https://example.test'));
      request.headers['User-Agent'] = 'my-app/1.0 kiota-dart/1.0.0';

      await client.send(request);

      expect(
        capturedRequest.headers['User-Agent'],
        equals('my-app/1.0 kiota-dart/1.0.0'),
      );
    });

    test(
      'appends user agent when existing agent contains user agent as substring',
      () async {
        late http.BaseRequest capturedRequest;
        final inner = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        });

        final client = UserAgentClient(inner, userAgent: 'kiota-dart/1.0.0');
        final request = http.Request('GET', Uri.parse('https://example.test'));
        request.headers['User-Agent'] = 'kiota-dart/1.0.0-preview';

        await client.send(request);

        expect(
          capturedRequest.headers['User-Agent'],
          equals('kiota-dart/1.0.0-preview kiota-dart/1.0.0'),
        );
      },
    );

    test(
      'does not duplicate multi-product user agent when already present',
      () async {
        late http.BaseRequest capturedRequest;
        final inner = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        });

        final client = UserAgentClient(
          inner,
          userAgent: 'my-sdk/2.0 kiota-dart/1.0.0',
        );
        final request = http.Request('GET', Uri.parse('https://example.test'));
        request.headers['User-Agent'] = 'my-sdk/2.0 kiota-dart/1.0.0';

        await client.send(request);

        expect(
          capturedRequest.headers['User-Agent'],
          equals('my-sdk/2.0 kiota-dart/1.0.0'),
        );
      },
    );

    test(
      'does not duplicate multi-product user agent sequence embedded among other agents',
      () async {
        late http.BaseRequest capturedRequest;
        final inner = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        });

        final client = UserAgentClient(
          inner,
          userAgent: 'my-sdk/2.0 kiota-dart/1.0.0',
        );
        final request = http.Request('GET', Uri.parse('https://example.test'));
        request.headers['User-Agent'] =
            'custom-client/1.0 my-sdk/2.0 kiota-dart/1.0.0 postman/10.0';

        await client.send(request);

        expect(
          capturedRequest.headers['User-Agent'],
          equals('custom-client/1.0 my-sdk/2.0 kiota-dart/1.0.0 postman/10.0'),
        );
      },
    );

    test(
      'appends multi-product user agent when only part of product list is present',
      () async {
        late http.BaseRequest capturedRequest;
        final inner = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        });

        final client = UserAgentClient(
          inner,
          userAgent: 'my-sdk/2.0 kiota-dart/1.0.0',
        );
        final request = http.Request('GET', Uri.parse('https://example.test'));
        request.headers['User-Agent'] = 'my-sdk/2.0';

        await client.send(request);

        expect(
          capturedRequest.headers['User-Agent'],
          equals('my-sdk/2.0 my-sdk/2.0 kiota-dart/1.0.0'),
        );
      },
    );
  });
}
