part of '../../microsoft_kiota_abstractions.dart';

/// Extensions for [Duration].
extension DurationExtensions on Duration {
  /// Formats this duration as ISO 8601, preserving microsecond precision.
  String toIso8601String() {
    if (this == Duration.zero) {
      return 'PT0S';
    }

    final days = inDays.abs();
    final hours = inHours.remainder(Duration.hoursPerDay).abs();
    final minutes = inMinutes.remainder(Duration.minutesPerHour).abs();
    final seconds = inSeconds.remainder(Duration.secondsPerMinute).abs();
    final microseconds = inMicroseconds
        .remainder(Duration.microsecondsPerSecond)
        .abs();
    final result = StringBuffer(isNegative ? '-P' : 'P');
    if (days != 0) {
      result.write('${days}D');
    }
    if (hours != 0 || minutes != 0 || seconds != 0 || microseconds != 0) {
      result.write('T');
      if (hours != 0) {
        result.write('${hours}H');
      }
      if (minutes != 0) {
        result.write('${minutes}M');
      }
      if (seconds != 0 || microseconds != 0) {
        result.write(seconds);
        if (microseconds != 0) {
          final fraction = microseconds
              .toString()
              .padLeft(6, '0')
              .replaceFirst(RegExp(r'0+$'), '');
          result.write('.$fraction');
        }
        result.write('S');
      }
    }
    return result.toString();
  }

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
