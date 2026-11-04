part of '../microsoft_kiota_abstractions.dart';

/// Represents the headers of a request.
///
/// Internally, the keys are stored in lower case, but the original case is
/// preserved when iterating over the headers.
/// This effectively makes the keys case-insensitive.
class HttpHeaders extends CaseInsensitiveMap<String, Set<String>> {
  /// Creates a new instance of [HttpHeaders].
  HttpHeaders();

  /// This list contains HTTP headers that can never have more than one value.
  ///
  /// Unlike normal HTTP headers, these can only appear once and cannot have
  /// multiple values separated with commas.
  ///
  /// When setting any of these, only the first value will be stored.
  static const List<String> singleValueHeaders = [
    'content-type',
    'content-encoding',
    'content-length',
  ];

  @override
  void operator []=(String key, Set<String> value) {
    final lowerCaseKey = key.toLowerCase();

    final Set<String> normalizedValue;
    if (singleValueHeaders.contains(lowerCaseKey)) {
      normalizedValue = value.isEmpty ? <String>{} : {value.first};
    } else {
      normalizedValue = value;
    }

    super[key] = normalizedValue;
  }

  /// Sets the value of the header with the given [key] to a Set containing only
  /// [value].
  void put(String key, String value) {
    this[key] = {value};
  }

  /// Adds a [value] to the header with the given [key].
  ///
  /// If the header does not exist, it is created with [value].
  /// If the header already exists and is not a single-value header,
  /// the [value] is added to the existing set of values.
  void add(String key, String value) {
    final lowerCaseKey = key.toLowerCase();
    if (singleValueHeaders.contains(lowerCaseKey)) {
      put(key, value);
      return;
    }

    final existing = this[key];
    if (existing == null || existing.isEmpty) {
      put(key, value);
    } else {
      this[key] = {...existing, value};
    }
  }

  /// Adds a [value] to the header with the given [key] only if the header
  /// is not already set with a non-empty value.
  ///
  /// Returns `true` if added, `false` otherwise.
  bool tryAdd(String key, String value) {
    final existing = this[key];
    if (existing != null && existing.isNotEmpty) {
      return false;
    }

    put(key, value);
    return true;
  }
}
