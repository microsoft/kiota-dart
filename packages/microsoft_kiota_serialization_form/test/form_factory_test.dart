import 'dart:convert';
import 'dart:typed_data';

import 'package:microsoft_kiota_serialization_form/microsoft_kiota_serialization_form.dart';
import 'package:test/test.dart';

void main() {
  group('FormParseNodeFactory', () {
    test('getRootParseNode with parameters and whitespace', () {
      final factory = FormParseNodeFactory();
      final content = Uint8List.fromList(utf8.encode('key=value'));

      final node1 = factory.getRootParseNode(
        'application/x-www-form-urlencoded; charset=utf-8',
        content,
      );
      expect(node1.getChildNode('key')?.getStringValue(), equals('value'));

      final node2 = factory.getRootParseNode(
        '  APPLICATION/X-WWW-FORM-URLENCODED; charset=utf-8  ',
        content,
      );
      expect(node2.getChildNode('key')?.getStringValue(), equals('value'));
    });

    test('getRootParseNode throws on invalid content type', () {
      final factory = FormParseNodeFactory();
      final content = Uint8List.fromList(utf8.encode('key=value'));

      expect(
        () => factory.getRootParseNode('application/json', content),
        throwsArgumentError,
      );
    });
  });

  group('FormSerializationWriterFactory', () {
    test('getSerializationWriter with parameters and whitespace', () {
      final factory = FormSerializationWriterFactory();

      final writer1 = factory.getSerializationWriter(
        'application/x-www-form-urlencoded; charset=utf-8',
      );
      expect(writer1, isNotNull);

      final writer2 = factory.getSerializationWriter(
        '  APPLICATION/X-WWW-FORM-URLENCODED; charset=utf-8  ',
      );
      expect(writer2, isNotNull);
    });

    test('getSerializationWriter throws on invalid content type', () {
      final factory = FormSerializationWriterFactory();

      expect(
        () => factory.getSerializationWriter('application/json'),
        throwsArgumentError,
      );
    });
  });
}
