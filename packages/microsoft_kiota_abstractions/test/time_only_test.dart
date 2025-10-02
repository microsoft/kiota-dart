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
  });
}
