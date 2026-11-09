part of '../microsoft_kiota_abstractions.dart';

/// Interface for a time only object that represents a time of day.
///
/// This interface provides an abstraction layer over time only objects.
/// It is used to represent time only values in a serialization format agnostic
/// way.
abstract class TimeOnly implements Comparable<TimeOnly> {
  /// Extracts the time part of a [DateTime] and creates an object implementing
  /// [TimeOnly].
  factory TimeOnly.fromDateTime(DateTime dateTime) {
    return _TimeOnlyImpl(
      hours: dateTime.hour,
      minutes: dateTime.minute,
      seconds: dateTime.second,
      milliseconds: dateTime.millisecond,
    );
  }

  /// This factory uses the [DateTime.parse] method to create an object
  /// implementing [TimeOnly].
  factory TimeOnly.fromDateTimeString(String dateTimeString) {
    final dateTime = DateTime.parse('2024-01-01 $dateTimeString');

    return TimeOnly.fromDateTime(dateTime);
  }

  /// Constructs an object implementing [TimeOnly] from the provided components.
  factory TimeOnly.fromComponents(
    int hours,
    int minutes, [
    int seconds = 0,
    int milliseconds = 0,
  ]) {
    return _TimeOnlyImpl(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  static final RegExp _timeRegex = RegExp(
    r'^(\d{1,2})(?::(\d{2})(?::(\d{2})(?:\.(\d+))?)?)?$',
  );

  /// Creates an object implementing [TimeOnly] from the provided string.
  ///
  /// Returns `null` if [timeString] is null, empty, or cannot be parsed as a
  /// valid time of day.
  static TimeOnly? tryParse(String? timeString) {
    if (timeString == null) {
      return null;
    }
    final trimmed = timeString.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final match = _timeRegex.firstMatch(trimmed);
    if (match == null) {
      return null;
    }

    final hours = int.tryParse(match.group(1)!);
    if (hours == null || hours < 0 || hours > 23) {
      return null;
    }

    final minutesGroup = match.group(2);
    final minutes = minutesGroup != null ? int.tryParse(minutesGroup) : 0;
    if (minutes == null || minutes < 0 || minutes > 59) {
      return null;
    }

    final secondsGroup = match.group(3);
    final seconds = secondsGroup != null ? int.tryParse(secondsGroup) : 0;
    if (seconds == null || seconds < 0 || seconds > 59) {
      return null;
    }

    final fractionGroup = match.group(4);
    var milliseconds = 0;
    if (fractionGroup != null && fractionGroup.isNotEmpty) {
      final padded = fractionGroup.padRight(3, '0');
      milliseconds = int.tryParse(padded.substring(0, 3)) ?? 0;
    }

    return TimeOnly.fromComponents(hours, minutes, seconds, milliseconds);
  }

  /// Gets the hours of the time.
  int get hours;

  /// Gets the minutes of the time.
  int get minutes;

  /// Gets the seconds of the time.
  int get seconds;

  /// Gets the milliseconds of the time.
  int get milliseconds;
}

@immutable
class _TimeOnlyImpl implements TimeOnly {
  const _TimeOnlyImpl({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.milliseconds,
  });

  @override
  final int hours;

  @override
  final int minutes;

  @override
  final int seconds;

  @override
  final int milliseconds;

  @override
  int compareTo(TimeOnly other) {
    if (hours != other.hours) {
      return hours.compareTo(other.hours);
    }

    if (minutes != other.minutes) {
      return minutes.compareTo(other.minutes);
    }

    if (seconds != other.seconds) {
      return seconds.compareTo(other.seconds);
    }

    return milliseconds.compareTo(other.milliseconds);
  }

  @override
  bool operator ==(Object other) {
    if (other is TimeOnly) {
      return compareTo(other) == 0;
    }

    return false;
  }

  @override
  int get hashCode =>
      hours.hashCode ^
      minutes.hashCode ^
      seconds.hashCode ^
      milliseconds.hashCode;
}
