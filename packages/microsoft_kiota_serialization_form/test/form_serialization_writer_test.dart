import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_form/microsoft_kiota_serialization_form.dart';
import 'package:test/test.dart';

String? _httpMethodEnumSerializer(HttpMethod? value) => value?.name;

void main() {
  group('FormSerializationWriter', () {
    test('writeEnumValue', () {
      final writer = FormSerializationWriter()
        ..writeEnumValue('key', HttpMethod.get, _httpMethodEnumSerializer);

      expect(utf8.decode(writer.getSerializedContent()), equals('key=get'));
    });

    test('writeCollectionOfEnumValues', () {
      final writer = FormSerializationWriter()
        ..writeCollectionOfEnumValues('key', [
          HttpMethod.get,
          HttpMethod.post,
        ], _httpMethodEnumSerializer);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('key=get%2Cpost'),
      );
    });

    test('writes empty string value as key with empty value', () {
      final writer = FormSerializationWriter()
        ..writeStringValue('filter', '')
        ..writeStringValue('name', 'test');

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('filter=&name=test'),
      );
    });

    test('writes byte array with base64 padding and empty byte array', () {
      final writer = FormSerializationWriter()
        ..writeByteArrayValue(
          'avatar',
          Uint8List.fromList([116, 101, 115, 116]),
        )
        ..writeByteArrayValue('empty', Uint8List(0));

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('avatar=dGVzdA%3D%3D&empty='),
      );
    });

    test('writes additional data with empty string values', () {
      final writer = FormSerializationWriter()
        ..writeAdditionalData({'key': '', 'count': 0});

      final result = utf8.decode(writer.getSerializedContent());
      expect(result, contains('key='));
      expect(result, contains('count=0'));
    });
  });
}
