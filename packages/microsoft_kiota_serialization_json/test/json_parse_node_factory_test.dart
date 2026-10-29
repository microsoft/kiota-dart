import 'dart:convert';

import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParseNodeFactoryTest', () {
    test('getParseNodeForJsonContentType', () {
      final json = utf8.encode('{"key":"value"}');
      final factory = JsonParseNodeFactory();
      final jsonParseNode = factory.getRootParseNode(
        factory.validContentType,
        json,
      );
      expect(jsonParseNode, isNotNull);
    });

    test('getRootParseNode with parameters and whitespace', () {
      final json = utf8.encode('{"key":"value"}');
      final factory = JsonParseNodeFactory();

      final node1 = factory.getRootParseNode(
        'application/json; charset=utf-8',
        json,
      );
      expect(node1.getChildNode('key')?.getStringValue(), equals('value'));

      final node2 = factory.getRootParseNode(
        '  APPLICATION/JSON; charset=utf-8  ',
        json,
      );
      expect(node2.getChildNode('key')?.getStringValue(), equals('value'));

      final node3 = factory.getRootParseNode(
        'application/json; odata.metadata=minimal',
        json,
      );
      expect(node3.getChildNode('key')?.getStringValue(), equals('value'));
    });

    test('testThrowsExceptionForInvalidContentType', () {
      const streamContentType = 'application/octet-stream';
      final json = utf8.encode('{"key":"value"}');
      final factory = JsonParseNodeFactory();
      expect(
        () => factory.getRootParseNode(streamContentType, json),
        throwsArgumentError,
      );
    });
  });
}
