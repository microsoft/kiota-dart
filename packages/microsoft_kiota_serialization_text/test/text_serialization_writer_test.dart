import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_text/microsoft_kiota_serialization_text.dart';
import 'package:test/test.dart';

import 'text_test_helper.dart';

String? _httpMethodEnumSerializer(HttpMethod? value) => value?.name;

void main() {
  group('TextSerializationWriter', () {
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
        final writer = TextSerializationWriter()
          ..writeDurationValue(null, entry.key);
        final serialized = utf8.decode(writer.getSerializedContent());

        expect(serialized, equals(entry.value));
        expect(TextParseNode(serialized).getDurationValue(), equals(entry.key));
      });
    }
    test('omits null duration values', () {
      final writer = TextSerializationWriter()..writeDurationValue(null, null);

      expect(writer.getSerializedContent(), isEmpty);
    });

    test('writeEnumValue', () {
      final writer = TextSerializationWriter()
        ..writeEnumValue(null, HttpMethod.get, _httpMethodEnumSerializer);

      expect(utf8.decode(writer.getSerializedContent()), equals('get'));
    });

    test('writeCollectionOfEnumValues', () {
      final writer = TextSerializationWriter();

      expect(
        () => writer.writeCollectionOfEnumValues(null, [
          HttpMethod.get,
          HttpMethod.post,
        ], _httpMethodEnumSerializer),
        throwsNoStructuredDataError,
      );
    });
  });
}
