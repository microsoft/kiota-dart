import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:test/test.dart';

void main() {
  group('DurationExtensions', () {
    test('tryParse simple', () {
      const input = 'P4DT12H30M5S';
      const expected = Duration(days: 4, hours: 12, minutes: 30, seconds: 5);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse with milliseconds', () {
      const input = 'PT5.123S';
      const expected = Duration(seconds: 5, milliseconds: 123);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse with overflow', () {
      const input = 'PT36H65M61S';
      const expected = Duration(hours: 36, minutes: 65, seconds: 61);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse with all negative', () {
      const input = '-P4DT12H30M5S';
      const expected = Duration(
        days: -4,
        hours: -12,
        minutes: -30,
        seconds: -5,
      );

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse with single negative', () {
      const input = 'P4DT-12H30M5S';
      const expected = Duration(days: 4, hours: -12, minutes: 30, seconds: 5);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse one year', () {
      const input = 'P1Y';
      const expected = Duration(days: 365);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse one month', () {
      const input = 'P1M';
      const expected = Duration(days: 30);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse one week', () {
      const input = 'P1W';
      const expected = Duration(days: 7);

      final actual = DurationExtensions.tryParse(input);

      expect(actual, equals(expected));
    });

    test('tryParse returns null on null, empty, or invalid input', () {
      expect(DurationExtensions.tryParse(null), isNull);
      expect(DurationExtensions.tryParse(''), isNull);
      expect(DurationExtensions.tryParse('   '), isNull);
      expect(DurationExtensions.tryParse('not-a-duration'), isNull);
      expect(DurationExtensions.tryParse('P'), isNull);
      expect(DurationExtensions.tryParse('12345'), isNull);
    });
  });
}
