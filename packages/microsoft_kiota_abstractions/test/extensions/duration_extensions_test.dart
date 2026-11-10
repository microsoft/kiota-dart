import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:test/test.dart';

void main() {
  group('DurationExtensions', () {
    final isoDurations = {
      Duration.zero: 'PT0S',
      const Duration(hours: 2): 'PT2H',
      const Duration(minutes: 1): 'PT1M',
      const Duration(seconds: 1): 'PT1S',
      const Duration(days: 2): 'P2D',
      const Duration(days: 1, hours: 2, minutes: 30): 'P1DT2H30M',
      const Duration(hours: 40): 'P1DT16H',
      const Duration(milliseconds: 500): 'PT0.5S',
      const Duration(microseconds: 1): 'PT0.000001S',
      const Duration(seconds: 5, milliseconds: 123, microseconds: 456):
          'PT5.123456S',
      const Duration(minutes: -1): '-PT1M',
      const Duration(microseconds: -1): '-PT0.000001S',
      const Duration(days: -2): '-P2D',
      const Duration(
        days: -3,
        hours: -4,
        minutes: -5,
        seconds: -6,
        microseconds: -123456,
      ): '-P3DT4H5M6.123456S',
      const Duration(days: 400, microseconds: 1): 'P400DT0.000001S',
    };
    for (final entry in isoDurations.entries) {
      test('toIso8601String produces and round-trips ${entry.value}', () {
        final actual = entry.key.toIso8601String();

        expect(actual, equals(entry.value));
        expect(DurationExtensions.tryParse(actual), equals(entry.key));
      });
    }

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
  });
}
