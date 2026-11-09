// ignore_for_file: avoid_redundant_argument_values

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:test/test.dart';

void main() {
  group('DateOnly', () {
    test('fromDateTimeString and toRfc3339String', () {
      expect(
        DateOnly.fromDateTimeString('2021-01-01').toRfc3339String(),
        '2021-01-01',
      );
    });

    test('round trip', () {
      final fromString = DateOnly.fromDateTimeString('2021-01-01');
      final toString = fromString.toRfc3339String();
      expect(toString, '2021-01-01');

      final roundTrip = DateOnly.fromDateTimeString(toString);
      final roundTripString = roundTrip.toRfc3339String();
      expect(roundTripString, '2021-01-01');
    });

    test('fromDateTime', () {
      final dateTime = DateTime(2024, 2, 3, 12, 34, 56);
      expect(DateOnly.fromDateTime(dateTime).toRfc3339String(), '2024-02-03');
    });

    test('fromComponents', () {
      expect(
        DateOnly.fromComponents(2021, 1, 1).toRfc3339String(),
        '2021-01-01',
      );
    });

    test('tryParse valid and invalid strings', () {
      expect(
        DateOnly.tryParse('2021-01-01')?.toRfc3339String(),
        equals('2021-01-01'),
      );
      expect(
        DateOnly.tryParse('2024-02-29')?.toRfc3339String(),
        equals('2024-02-29'),
      );
      expect(DateOnly.tryParse(null), isNull);
      expect(DateOnly.tryParse(''), isNull);
      expect(DateOnly.tryParse('   '), isNull);
      expect(DateOnly.tryParse('invalid-date'), isNull);
      expect(DateOnly.tryParse('not a date'), isNull);
      expect(DateOnly.tryParse('2023-02-29'), isNull);
      expect(DateOnly.tryParse('2021-04-31'), isNull);
      // Rejects strings with time components or timezone offsets
      expect(DateOnly.tryParse('2021-01-01T23:00:00-05:00'), isNull);
      expect(DateOnly.tryParse('2021-01-01T00:00:00Z'), isNull);
      expect(DateOnly.tryParse('2021-01-01 12:00:00'), isNull);
    });
  });
}
