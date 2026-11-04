import 'package:http/http.dart' as http;
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_http/microsoft_kiota_http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'http_client_request_adapter_test.mocks.dart';

@GenerateMocks([
  http.Client,
  AuthenticationProvider,
  ParseNodeFactory,
  SerializationWriterFactory,
  ParseNode,
])
void main() {
  group('HttpClientRequestAdapter', () {
    test('sendPrimitive String', () async {
      final client = MockClient();
      final authProvider = MockAuthenticationProvider();
      final pNodeFactory = MockParseNodeFactory();
      final sWriterFactory = MockSerializationWriterFactory();
      final parseNode = MockParseNode();

      const stringContent = 'Hello, World!';
      final contentBytes = Uint8List.fromList(stringContent.codeUnits);

      final adapter = HttpClientRequestAdapter(
        authProvider: authProvider,
        pNodeFactory: pNodeFactory,
        sWriterFactory: sWriterFactory,
        client: client,
      );

      final info = RequestInformation(
        httpMethod: HttpMethod.get,
        urlTemplate: 'https://example.test/primitive',
      );

      when(
        authProvider.authenticateRequest(info),
      ).thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([contentBytes]),
          200,
          headers: {'content-type': 'text/plain'},
        );
      });

      when(
        pNodeFactory.getRootParseNode('text/plain', contentBytes),
      ).thenReturn(parseNode);

      when(parseNode.getStringValue()).thenReturn(stringContent);

      final stringResult = await adapter.sendPrimitive<String>(info);

      expect(stringResult, isNotNull);
      expect(stringResult, stringContent);
    });

    test('sendPrimitive nullable String', () async {
      final client = MockClient();
      final authProvider = MockAuthenticationProvider();
      final pNodeFactory = MockParseNodeFactory();
      final sWriterFactory = MockSerializationWriterFactory();
      final parseNode = MockParseNode();

      const stringContent = 'Hello, World!';
      final contentBytes = Uint8List.fromList(stringContent.codeUnits);

      final adapter = HttpClientRequestAdapter(
        authProvider: authProvider,
        pNodeFactory: pNodeFactory,
        sWriterFactory: sWriterFactory,
        client: client,
      );

      final info = RequestInformation(
        httpMethod: HttpMethod.get,
        urlTemplate: 'https://example.test/primitive',
      );

      when(
        authProvider.authenticateRequest(info),
      ).thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([contentBytes]),
          200,
          headers: {'content-type': 'text/plain'},
        );
      });

      when(
        pNodeFactory.getRootParseNode('text/plain', contentBytes),
      ).thenReturn(parseNode);

      when(parseNode.getStringValue()).thenReturn(stringContent);

      final stringResult = await adapter.sendPrimitive<String?>(info);

      expect(stringResult, isNotNull);
      expect(stringResult, stringContent);
    });

    test('sendPrimitive Uint8List', () async {
      final client = MockClient();
      final authProvider = MockAuthenticationProvider();
      final pNodeFactory = MockParseNodeFactory();
      final sWriterFactory = MockSerializationWriterFactory();
      final parseNode = MockParseNode();

      final expectedBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final adapter = HttpClientRequestAdapter(
        authProvider: authProvider,
        pNodeFactory: pNodeFactory,
        sWriterFactory: sWriterFactory,
        client: client,
      );

      final info = RequestInformation(
        httpMethod: HttpMethod.get,
        urlTemplate: 'https://example.test/primitive',
      );

      when(
        authProvider.authenticateRequest(info),
      ).thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([expectedBytes]),
          200,
          headers: {'content-type': 'application/octet-stream'},
        );
      });

      when(
        pNodeFactory.getRootParseNode(
          'application/octet-stream',
          expectedBytes,
        ),
      ).thenReturn(parseNode);

      when(parseNode.getByteArrayValue()).thenReturn(expectedBytes);

      final result = await adapter.sendPrimitive<Uint8List>(info);

      expect(result, isNotNull);
      expect(result, expectedBytes);

      when(parseNode.getByteArrayValue()).thenReturn(null);

      final nullResult = await adapter.sendPrimitive<Uint8List>(info);

      expect(nullResult, isNull);
    });

    test('sendPrimitive nullable Uint8List', () async {
      final client = MockClient();
      final authProvider = MockAuthenticationProvider();
      final pNodeFactory = MockParseNodeFactory();
      final sWriterFactory = MockSerializationWriterFactory();
      final parseNode = MockParseNode();

      final expectedBytes = Uint8List.fromList([42, 43, 44]);

      final adapter = HttpClientRequestAdapter(
        authProvider: authProvider,
        pNodeFactory: pNodeFactory,
        sWriterFactory: sWriterFactory,
        client: client,
      );

      final info = RequestInformation(
        httpMethod: HttpMethod.get,
        urlTemplate: 'https://example.test/primitive',
      );

      when(
        authProvider.authenticateRequest(info),
      ).thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([expectedBytes]),
          200,
          headers: {'content-type': 'application/octet-stream'},
        );
      });

      when(
        pNodeFactory.getRootParseNode(
          'application/octet-stream',
          expectedBytes,
        ),
      ).thenReturn(parseNode);

      when(parseNode.getByteArrayValue()).thenReturn(expectedBytes);

      final result = await adapter.sendPrimitive<Uint8List?>(info);

      expect(result, isNotNull);
      expect(result, expectedBytes);

      when(parseNode.getByteArrayValue()).thenReturn(null);

      final nullResult = await adapter.sendPrimitive<Uint8List?>(info);

      expect(nullResult, isNull);
    });

    test('sendPrimitive throws for unsupported types', () async {
      final client = MockClient();
      final authProvider = MockAuthenticationProvider();
      final pNodeFactory = MockParseNodeFactory();
      final sWriterFactory = MockSerializationWriterFactory();
      final parseNode = MockParseNode();

      const stringContent = 'Hello, World!';
      final contentBytes = Uint8List.fromList(stringContent.codeUnits);

      final adapter = HttpClientRequestAdapter(
        authProvider: authProvider,
        pNodeFactory: pNodeFactory,
        sWriterFactory: sWriterFactory,
        client: client,
      );

      final info = RequestInformation(
        httpMethod: HttpMethod.get,
        urlTemplate: 'https://example.test/primitive',
      );

      when(
        authProvider.authenticateRequest(info),
      ).thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([contentBytes]),
          200,
          headers: {'content-type': 'text/plain'},
        );
      });

      when(
        pNodeFactory.getRootParseNode('text/plain', contentBytes),
      ).thenReturn(parseNode);

      when(parseNode.getStringValue()).thenReturn(stringContent);

      expect(
        () => adapter.sendPrimitive<Object?>(info),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('convertToNativeRequest sets base URL and converts request', () async {
      final client = MockClient();
      final authProvider = MockAuthenticationProvider();
      final pNodeFactory = MockParseNodeFactory();
      final sWriterFactory = MockSerializationWriterFactory();

      final adapter = HttpClientRequestAdapter(
        authProvider: authProvider,
        pNodeFactory: pNodeFactory,
        sWriterFactory: sWriterFactory,
        client: client,
      )..baseUrl = 'https://example.test';

      final info = RequestInformation(
        httpMethod: HttpMethod.get,
        urlTemplate: '{+baseurl}/items',
      );

      when(
        authProvider.authenticateRequest(info),
      ).thenAnswer((_) async => Future<void>.value());

      final native = await adapter.convertToNativeRequest<http.Request>(info);
      expect(native, isNotNull);
      expect(native!.method, equals('GET'));
      expect(native.url, equals(Uri.parse('https://example.test/items')));
    });

    test(
      'convertToNativeRequest throws ArgumentError when httpMethod is null',
      () async {
        final client = MockClient();
        final authProvider = MockAuthenticationProvider();
        final pNodeFactory = MockParseNodeFactory();
        final sWriterFactory = MockSerializationWriterFactory();

        final adapter = HttpClientRequestAdapter(
          authProvider: authProvider,
          pNodeFactory: pNodeFactory,
          sWriterFactory: sWriterFactory,
          client: client,
        );

        final info = RequestInformation(
          urlTemplate: 'https://example.test/items',
        );

        when(
          authProvider.authenticateRequest(info),
        ).thenAnswer((_) async => Future<void>.value());

        expect(
          () => adapter.convertToNativeRequest<http.Request>(info),
          throwsA(isA<ArgumentError>()),
        );
      },
    );
  });
}
