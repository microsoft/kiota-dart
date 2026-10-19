import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'parse_node_factory_registry_test.mocks.dart';

@GenerateMocks([ParseNodeFactory, ParseNode])
void main() {
  group('ParseNodeFactoryRegistry', () {
    test('VendorSpecificContentType', () {
      const contentType = 'application/json';
      final mockFactory = MockParseNodeFactory();
      final jsonStream = utf8.encode('{"test": "input"}');
      final mockParseNode = MockParseNode();
      when(
        mockFactory.getRootParseNode(contentType, jsonStream),
      ).thenReturn(mockParseNode);
      ParseNodeFactoryRegistry.defaultInstance.contentTypeAssociatedFactories
          .putIfAbsent(contentType, () => mockFactory);
      final rootParseNode = ParseNodeFactoryRegistry.defaultInstance
          .getRootParseNode('application/vnd+json', jsonStream);
      expect(rootParseNode, isNotNull);
    });

    test('ContentTypeWithOptionalWhitespace', () {
      const contentType = 'application/json';
      final mockFactory = MockParseNodeFactory();
      final jsonStream = utf8.encode('{"test": "input"}');
      final mockParseNode = MockParseNode();
      when(
        mockFactory.getRootParseNode(contentType, jsonStream),
      ).thenReturn(mockParseNode);
      final registry = ParseNodeFactoryRegistry();
      registry.contentTypeAssociatedFactories[contentType] = mockFactory;
      final rootParseNode = registry.getRootParseNode(
        'application/json ; charset=utf-8',
        jsonStream,
      );
      expect(rootParseNode, isNotNull);
    });
  });
}
