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

  /// Creates an object implementing [TimeOnly] from the provided string using
  /// [DateTime.tryParse].
  ///
  /// Returns `null` if [dateTimeString] is null, empty, or cannot be parsed.
  static TimeOnly? tryParse(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.trim().isEmpty) {
      return null;
    }

    final dateTime = DateTime.tryParse('2024-01-01 $dateTimeString');
    if (dateTime == null) {
      return null;
    }

    return TimeOnly.fromDateTime(dateTime);
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
