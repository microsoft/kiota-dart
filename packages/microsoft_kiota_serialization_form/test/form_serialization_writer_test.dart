import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_form/microsoft_kiota_serialization_form.dart';
import 'package:test/test.dart';

String? _httpMethodEnumSerializer(HttpMethod? value) => value?.name;

void main() {
  group('FormSerializationWriter', () {
    final isoDurations = {
      Duration.zero: 'PT0S',
      const Duration(hours: 2): 'PT2H',
      const Duration(days: 2): 'P2D',
      const Duration(days: 1, hours: 2, minutes: 30): 'P1DT2H30M',
      const Duration(milliseconds: 500): 'PT0.5S',
      const Duration(seconds: 5, microseconds: 123456): 'PT5.123456S',
      const Duration(microseconds: 1): 'PT0.000001S',
      const Duration(minutes: -1): '-PT1M',
      const Duration(microseconds: -1): '-PT0.000001S',
      const Duration(days: -3, hours: -4, seconds: -5): '-P3DT4H5S',
    };
    for (final entry in isoDurations.entries) {
      test('writes and round-trips ${entry.value}', () {
        final writer = FormSerializationWriter()
          ..writeDurationValue('duration', entry.key);
        final serialized = utf8.decode(writer.getSerializedContent());

        expect(serialized, equals('duration=${entry.value}'));
        expect(
          FormParseNode(
            serialized,
          ).getChildNode('duration')?.getDurationValue(),
          equals(entry.key),
        );
      });
    }
    test('omits null duration values', () {
      final writer = FormSerializationWriter()
        ..writeDurationValue('duration', null);

      expect(writer.getSerializedContent(), isEmpty);
    });

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

    test('writes additional data with byte array and empty byte array', () {
      final writer = FormSerializationWriter()
        ..writeAdditionalData({
          'avatar': Uint8List.fromList([116, 101, 115, 116]),
          'empty': Uint8List(0),
        });

      final result = utf8.decode(writer.getSerializedContent());
      expect(result, equals('avatar=dGVzdA%3D%3D&empty='));
    });

    test('writes collection of byte array primitive values', () {
      final writer = FormSerializationWriter()
        ..writeCollectionOfPrimitiveValues('files', [
          Uint8List.fromList([116, 101, 115, 116]),
          Uint8List(0),
        ]);

      final result = utf8.decode(writer.getSerializedContent());
      expect(result, equals('files=dGVzdA%3D%3D&files='));
    });

    group('round-trips with FormParseNode', () {
      test('round-trips byte array and empty byte array', () {
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final emptyBytes = Uint8List(0);
        final writer = FormSerializationWriter()
          ..writeByteArrayValue('data', bytes)
          ..writeByteArrayValue('empty', emptyBytes);

        final serialized = utf8.decode(writer.getSerializedContent());
        final root = FormParseNode(serialized);

        expect(root.getChildNode('data')?.getByteArrayValue(), equals(bytes));
        expect(
          root.getChildNode('empty')?.getByteArrayValue(),
          equals(emptyBytes),
        );
      });

      test('round-trips additional data containing byte arrays', () {
        final avatar = Uint8List.fromList([116, 101, 115, 116]);
        final empty = Uint8List(0);
        final writer = FormSerializationWriter()
          ..writeAdditionalData({'avatar': avatar, 'empty': empty});

        final serialized = utf8.decode(writer.getSerializedContent());
        final root = FormParseNode(serialized);

        expect(
          root.getChildNode('avatar')?.getByteArrayValue(),
          equals(avatar),
        );
        expect(root.getChildNode('empty')?.getByteArrayValue(), equals(empty));
      });

      test(
        'round-trips collection of byte arrays including plus and null payloads',
        () {
          final b1 = Uint8List.fromList([116, 101, 115, 116]);
          final b2 = Uint8List(0);
          final bPlus = Uint8List.fromList([251]); // Base64 '+w=='
          final bNull = Uint8List.fromList([158, 233, 101]); // Base64 'null'
          final writer = FormSerializationWriter()
            ..writeCollectionOfPrimitiveValues('files', [b1, b2, bPlus, bNull]);

          final serialized = utf8.decode(writer.getSerializedContent());
          final root = FormParseNode(serialized);

          expect(
            root
                .getChildNode('files')
                ?.getCollectionOfPrimitiveValues<Uint8List>(),
            equals([b1, b2, bPlus, bNull]),
          );
          expect(
            root
                .getChildNode('files')
                ?.getCollectionOfPrimitiveValues<Uint8List?>(),
            equals([b1, b2, bPlus, bNull]),
          );
        },
      );

      test('round-trips primitive collections of different types', () {
        final writer = FormSerializationWriter()
          ..writeCollectionOfPrimitiveValues('numbers', [1, 2, 3])
          ..writeCollectionOfPrimitiveValues('flags', [true, false])
          ..writeCollectionOfPrimitiveValues('strings', ['hello', 'world']);

        final serialized = utf8.decode(writer.getSerializedContent());
        final root = FormParseNode(serialized);

        expect(
          root.getChildNode('numbers')?.getCollectionOfPrimitiveValues<int>(),
          equals([1, 2, 3]),
        );
        expect(
          root.getChildNode('flags')?.getCollectionOfPrimitiveValues<bool>(),
          equals([true, false]),
        );
        expect(
          root
              .getChildNode('strings')
              ?.getCollectionOfPrimitiveValues<String>(),
          equals(['hello', 'world']),
        );
      });
    });
  });
}
