import 'dart:convert';
import 'package:microsoft_kiota_serialization_text/microsoft_kiota_serialization_text.dart';
import 'package:test/test.dart';

void main() {
  group('TextParseNodeFactory', () {
    test('getRootParseNode with parameters and whitespace', () {
      final factory = TextParseNodeFactory();
      final content = utf8.encode('hello text');

      final node1 = factory.getRootParseNode(
        'text/plain; charset=utf-8',
        content,
      );
      expect(node1.getStringValue(), equals('hello text'));

      final node2 = factory.getRootParseNode(
        '  TEXT/PLAIN; charset=utf-8  ',
        content,
      );
      expect(node2.getStringValue(), equals('hello text'));
    });

    test('getRootParseNode throws on invalid content type', () {
      final factory = TextParseNodeFactory();
      final content = utf8.encode('hello text');

      expect(
        () => factory.getRootParseNode('application/json', content),
        throwsArgumentError,
      );
    });
  });

  group('TextSerializationWriterFactory', () {
    test('getSerializationWriter with parameters and whitespace', () {
      final factory = TextSerializationWriterFactory();

      final writer1 = factory.getSerializationWriter(
        'text/plain; charset=utf-8',
      );
      expect(writer1, isNotNull);

      final writer2 = factory.getSerializationWriter(
        '  TEXT/PLAIN; charset=utf-8  ',
      );
      expect(writer2, isNotNull);
    });

    test('getSerializationWriter throws on invalid content type', () {
      final factory = TextSerializationWriterFactory();

      expect(
        () => factory.getSerializationWriter('application/json'),
        throwsArgumentError,
      );
    });
  });
}
