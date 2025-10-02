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
  });
}
