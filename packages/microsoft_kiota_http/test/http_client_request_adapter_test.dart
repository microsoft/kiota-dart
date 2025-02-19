import 'dart:typed_data';

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

      when(authProvider.authenticateRequest(info))
          .thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([contentBytes]),
          200,
          headers: {
            'content-type': 'text/plain',
          },
        );
      });

      when(pNodeFactory.getRootParseNode('text/plain', contentBytes))
          .thenReturn(parseNode);

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

      when(authProvider.authenticateRequest(info))
          .thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([contentBytes]),
          200,
          headers: {
            'content-type': 'text/plain',
          },
        );
      });

      when(pNodeFactory.getRootParseNode('text/plain', contentBytes))
          .thenReturn(parseNode);

      when(parseNode.getStringValue()).thenReturn(stringContent);

      final stringResult = await adapter.sendPrimitive<String?>(info);

      expect(stringResult, isNotNull);
      expect(stringResult, stringContent);
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

      when(authProvider.authenticateRequest(info))
          .thenAnswer((_) async => Future<void>.value());

      when(client.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.fromIterable([contentBytes]),
          200,
          headers: {
            'content-type': 'text/plain',
          },
        );
      });

      when(pNodeFactory.getRootParseNode('text/plain', contentBytes))
          .thenReturn(parseNode);

      when(parseNode.getStringValue()).thenReturn(stringContent);

      expect(
            () => adapter.sendPrimitive<Object?>(info),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
