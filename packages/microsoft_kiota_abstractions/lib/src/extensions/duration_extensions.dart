part of '../../microsoft_kiota_abstractions.dart';

/// Extensions for [Duration].
extension DurationExtensions on Duration {
  /// Tries to parse a [String] in the ISO 8601 format to a [Duration].
  static Duration? tryParse(String? value) {
    if (value == null) {
      return null;
    }

    // This regex is based on the ISO 8601 duration format
    final regex = RegExp(
      r'^([-+])?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$',
    );

    final match = regex.firstMatch(value);
    if (match == null) {
      return null;
    }

    final hasAnyComponent =
        match.group(2) != null ||
        match.group(3) != null ||
        match.group(4) != null ||
        match.group(5) != null ||
        match.group(6) != null ||
        match.group(7) != null ||
        match.group(8) != null;
    if (!hasAnyComponent) {
      return null;
    }

    final sign = match.group(1) == '-' ? -1 : 1;
    final fractionalYears = double.tryParse(match.group(2) ?? '') ?? 0;
    final fractionalMonths = double.tryParse(match.group(3) ?? '') ?? 0;
    final fractionalWeeks = double.tryParse(match.group(4) ?? '') ?? 0;
    final fractionalDays = double.tryParse(match.group(5) ?? '') ?? 0;
    final fractionalHours = double.tryParse(match.group(6) ?? '') ?? 0;
    final fractionalMinutes = double.tryParse(match.group(7) ?? '') ?? 0;
    final fractionalSeconds = double.tryParse(match.group(8) ?? '') ?? 0;

    final totalMicroseconds =
        (fractionalYears * 365 * Duration.microsecondsPerDay).round() +
        (fractionalMonths * 30 * Duration.microsecondsPerDay).round() +
        (fractionalWeeks * 7 * Duration.microsecondsPerDay).round() +
        (fractionalDays * Duration.microsecondsPerDay).round() +
        (fractionalHours * Duration.microsecondsPerHour).round() +
        (fractionalMinutes * Duration.microsecondsPerMinute).round() +
        (fractionalSeconds * Duration.microsecondsPerSecond).round();

    final days = totalMicroseconds ~/ Duration.microsecondsPerDay;
    final hours =
        (totalMicroseconds % Duration.microsecondsPerDay) ~/
        Duration.microsecondsPerHour;
    final minutes =
        (totalMicroseconds % Duration.microsecondsPerHour) ~/
        Duration.microsecondsPerMinute;
    final seconds =
        (totalMicroseconds % Duration.microsecondsPerMinute) ~/
        Duration.microsecondsPerSecond;
    final milliseconds =
        (totalMicroseconds % Duration.microsecondsPerSecond) ~/
        Duration.microsecondsPerMillisecond;
    final microseconds =
        totalMicroseconds % Duration.microsecondsPerMillisecond;

    return Duration(
      days: sign * days,
      hours: sign * hours,
      minutes: sign * minutes,
      seconds: sign * seconds,
      milliseconds: sign * milliseconds,
      microseconds: sign * microseconds,
    );
  }
}
