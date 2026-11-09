import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:test/test.dart';

void main() {
  group('TimeOnly', () {
    test('fromDateTimeString and toRfc3339String', () {
      expect(
        TimeOnly.fromDateTimeString('12:34:56').toRfc3339String(),
        '12:34:56',
      );
      expect(
        TimeOnly.fromDateTimeString('12:34').toRfc3339String(),
        '12:34:00',
      );
      expect(TimeOnly.fromDateTimeString('12').toRfc3339String(), '12:00:00');
    });

    test('round trip', () {
      final fromString = TimeOnly.fromDateTimeString('12:34:56.789');
      final toString = fromString.toRfc3339String();
      expect(toString, '12:34:56.789');

      final roundTrip = TimeOnly.fromDateTimeString(toString);
      final roundTripString = roundTrip.toRfc3339String();
      expect(roundTripString, '12:34:56.789');
    });

    test('fromDateTime', () {
      final dateTime = DateTime(2021, 1, 1, 12, 34, 56);
      expect(TimeOnly.fromDateTime(dateTime).toRfc3339String(), '12:34:56');
    });

    test('fromComponents', () {
      expect(
        TimeOnly.fromComponents(12, 34, 56, 789).toRfc3339String(),
        '12:34:56.789',
      );
      expect(TimeOnly.fromComponents(12, 34, 56).toRfc3339String(), '12:34:56');
      expect(TimeOnly.fromComponents(12, 34).toRfc3339String(), '12:34:00');
    });

    test('tryParse valid and invalid strings', () {
      expect(
        TimeOnly.tryParse('12:34:56')?.toRfc3339String(),
        equals('12:34:56'),
      );
      expect(TimeOnly.tryParse('12:34')?.toRfc3339String(), equals('12:34:00'));
      expect(TimeOnly.tryParse('12')?.toRfc3339String(), equals('12:00:00'));
      expect(
        TimeOnly.tryParse('12:34:56.789')?.toRfc3339String(),
        equals('12:34:56.789'),
      );
      expect(TimeOnly.tryParse(null), isNull);
      expect(TimeOnly.tryParse(''), isNull);
      expect(TimeOnly.tryParse('   '), isNull);
      expect(TimeOnly.tryParse('invalid-time'), isNull);
      expect(TimeOnly.tryParse('not a time'), isNull);
      expect(TimeOnly.tryParse('24:00:00'), isNull);
      expect(TimeOnly.tryParse('12:60:00'), isNull);
      expect(TimeOnly.tryParse('12:00:60'), isNull);
      // Rejects strings with timezone offsets to avoid wall-clock time shifts
      expect(TimeOnly.tryParse('12:00:00+02:00'), isNull);
      expect(TimeOnly.tryParse('12:00:00-05:00'), isNull);
      expect(TimeOnly.tryParse('12:00:00Z'), isNull);
    });
  });
}
