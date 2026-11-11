part of '../microsoft_kiota_abstractions.dart';

/// Interface for a date only object.
///
/// This interface provides an abstraction layer over date only objects.
/// It is used to represent date only values in a serialization format agnostic
/// way.
///
/// It can only be used to represent a date in the Gregorian calendar.
abstract class DateOnly implements Comparable<DateOnly> {
  /// Extracts the date part of a [DateTime] and creates an object implementing
  /// [DateOnly].
  factory DateOnly.fromDateTime(DateTime dateTime) {
    return _DateOnlyImpl(
      day: dateTime.day,
      month: dateTime.month,
      year: dateTime.year,
    );
  }

  /// This factory uses the [DateTime.parse] method to create an object
  /// implementing [DateOnly].
  factory DateOnly.fromDateTimeString(String dateTimeString) {
    final date = DateTime.parse(dateTimeString);

    return DateOnly.fromDateTime(date);
  }

  /// Creates an object implementing [DateOnly] from the provided components.
  factory DateOnly.fromComponents(int year, [int month = 1, int day = 1]) {
    return _DateOnlyImpl(day: day, month: month, year: year);
  }

  static final RegExp _dateRegex = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Creates an object implementing [DateOnly] from the provided string.
  ///
  /// Returns `null` if [dateString] is null, empty, or cannot be parsed as a
  /// valid RFC 3339 `full-date` (`YYYY-MM-DD`).
  static DateOnly? tryParse(String? dateString) {
    if (dateString == null) {
      return null;
    }
    final trimmed = dateString.trim();
    final match = _dateRegex.firstMatch(trimmed);
    if (match == null) {
      return null;
    }

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);

    if (year == null || month == null || day == null) {
      return null;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    try {
      final dateTime = DateTime.utc(year, month, day);
      if (dateTime.year != year ||
          dateTime.month != month ||
          dateTime.day != day) {
        return null;
      }
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return null;
    }

    return DateOnly.fromComponents(year, month, day);
  }

  /// Gets the year of the date.
  int get year;

  /// Gets the month of the date.
  int get month;

  /// Gets the day of the date.
  int get day;
}

@immutable
class _DateOnlyImpl implements DateOnly {
  const _DateOnlyImpl({
    required this.day,
    required this.month,
    required this.year,
  });

  @override
  final int day;

  @override
  final int month;

  @override
  final int year;

  @override
  int compareTo(DateOnly other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }

    if (month != other.month) {
      return month.compareTo(other.month);
    }

    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) {
    if (other is DateOnly) {
      return compareTo(other) == 0;
    }

    return false;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}
