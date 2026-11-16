part of '../microsoft_kiota_serialization_form.dart';

/// A helper to get a [Type] from a nullable generic parameter.
typedef _TypeOf<T> = T;

/// Represents a [ParseNode] that can be used to parse a form url encoded string.
class FormParseNode implements ParseNode {
  FormParseNode(String value)
    : _rawValue = value,
      _isDecoded = false,
      _fields = _parseFields(value);

  FormParseNode._fromDecodedValue(String value)
    : _rawValue = value,
      _isDecoded = true,
      _fields = const {};

  static Map<String, String> _parseFields(String value) {
    final fields = value.split('&');
    final result = CaseInsensitiveMap<String, List<String>>();

    for (final field in fields) {
      if (field.isEmpty) {
        continue;
      }

      final separatorIndex = field.indexOf('=');
      if (separatorIndex == -1) {
        continue;
      }

      final key = _sanitizeKey(field.substring(0, separatorIndex));
      if (key.isEmpty) {
        continue;
      }

      final value = _sanitizeValue(field.substring(separatorIndex + 1));

      if (!result.containsKey(key)) {
        result[key] = [];
      }

      result[key]!.add(value);
    }

    return result.map((key, values) => MapEntry(key, values.join(',')));
  }

  static String _sanitizeKey(String key) {
    return Uri.decodeQueryComponent(key.trim());
  }

  static String _sanitizeValue(String value) {
    return Uri.decodeQueryComponent(value.trim());
  }

  final String _rawValue;
  final bool _isDecoded;
  final Map<String, String> _fields;

  String get _decodedValue =>
      _isDecoded ? _rawValue : Uri.decodeQueryComponent(_rawValue);

  @override
  ParsableHook? onAfterAssignFieldValues;

  @override
  ParsableHook? onBeforeAssignFieldValues;

  static bool? _parseBoolValue(String value) {
    if (value.isEmpty) {
      return null;
    }
    return bool.tryParse(value);
  }

  /// Parses a Base64-encoded [Uint8List] value.
  ///
  /// Returns an empty [Uint8List] when the string value is empty,
  /// or `null` if the string cannot be decoded.
  static Uint8List? _parseByteArrayValue(String value) {
    if (value.isEmpty) {
      return Uint8List(0);
    }
    try {
      return base64Decode(value);
    } on FormatException {
      return null;
    }
  }

  static DateOnly? _parseDateOnlyValue(String value) {
    return DateOnly.tryParse(value);
  }

  static DateTime? _parseDateTimeValue(String value) {
    return DateTime.tryParse(value);
  }

  static double? _parseDoubleValue(String value) {
    return double.tryParse(value);
  }

  static Duration? _parseDurationValue(String value) {
    return DurationExtensions.tryParse(value);
  }

  // ignore: experimental_member_use
  static UuidValue? _parseGuidValue(String value) {
    if (value.isEmpty || value == 'null') {
      return null;
    }
    try {
      // ignore: experimental_member_use
      return UuidValue.withValidation(value);
    } on FormatException {
      return null;
    }
  }

  static int? _parseIntValue(String value) {
    return int.tryParse(value);
  }

  static String? _parseStringValue(String value) {
    if (value == 'null') {
      return null;
    }
    return value;
  }

  static TimeOnly? _parseTimeOnlyValue(String value) {
    return TimeOnly.tryParse(value);
  }

  static T? _parseEnumValue<T extends Enum>(
    String value,
    EnumFactory<T> parser,
  ) {
    if (value.isEmpty || value == 'null') {
      return null;
    }
    return parser(value);
  }

  @override
  bool? getBoolValue() => _parseBoolValue(_decodedValue);

  @override
  Uint8List? getByteArrayValue() => _parseByteArrayValue(_decodedValue);

  @override
  ParseNode? getChildNode(String identifier) {
    final sanitizedIdentifier = _sanitizeKey(identifier);

    if (!_fields.containsKey(sanitizedIdentifier)) {
      return null;
    }

    return FormParseNode._fromDecodedValue(_fields[sanitizedIdentifier]!)
      ..onAfterAssignFieldValues = onAfterAssignFieldValues
      ..onBeforeAssignFieldValues = onBeforeAssignFieldValues;
  }

  @override
  Iterable<T> getCollectionOfEnumValues<T extends Enum>(
    EnumFactory<T> parser,
  ) sync* {
    final collection = _decodedValue
        .split(',')
        .where((entry) => entry.isNotEmpty);

    for (final entry in collection) {
      final enumValue = _parseEnumValue(entry, parser);
      if (enumValue != null) {
        yield enumValue;
      }
    }
  }

  @override
  Iterable<T> getCollectionOfObjectValues<T extends Parsable>(
    ParsableFactory<T> factory,
  ) {
    throw UnsupportedError(
      'Collections are not supported with uri form encoding',
    );
  }

  /// Checks if [T] is exactly [U] or [U?].
  @pragma('vm:prefer-inline')
  static bool _isA<T, U>() => T == U || T == _TypeOf<U?>;

  /// Checks if [T] is a subtype of [U].
  @pragma('vm:prefer-inline')
  static bool _isSubtype<T, U>() => <T>[] is List<U>;

  /// Returns an [Iterable] of primitive values of type [T].
  ///
  /// Supports both non-nullable and nullable primitive types, as well as
  /// Base64-encoded [Uint8List] values.
  @override
  Iterable<T> getCollectionOfPrimitiveValues<T>() sync* {
    final isByteArray = _isA<T, Uint8List>() || _isSubtype<T, Uint8List?>();
    final entries = _decodedValue.split(',');
    final collection = isByteArray
        ? entries
        : entries.where((entry) => entry.isNotEmpty);

    final allowsNull = null is T;
    final T? Function(String entry) converter;

    if (_isA<T, bool>()) {
      converter = (v) => _parseBoolValue(v) as T?;
    } else if (_isA<T, int>()) {
      converter = (v) => _parseIntValue(v) as T?;
    } else if (_isA<T, double>()) {
      converter = (v) => _parseDoubleValue(v) as T?;
    } else if (_isA<T, String>()) {
      converter = (v) => _parseStringValue(v) as T?;
    } else if (_isA<T, DateTime>()) {
      converter = (v) => _parseDateTimeValue(v) as T?;
    } else if (_isA<T, DateOnly>()) {
      converter = (v) => _parseDateOnlyValue(v) as T?;
    } else if (_isA<T, TimeOnly>()) {
      converter = (v) => _parseTimeOnlyValue(v) as T?;
    } else if (_isA<T, Duration>()) {
      converter = (v) => _parseDurationValue(v) as T?;
      // ignore: experimental_member_use
    } else if (_isA<T, UuidValue>()) {
      // ignore: experimental_member_use
      converter = (v) => _parseGuidValue(v) as T?;
    } else if (isByteArray) {
      converter = (v) => _parseByteArrayValue(v) as T?;
    } else {
      throw UnsupportedError('Unsupported primitive type $T');
    }

    for (final entry in collection) {
      if (!isByteArray && entry == 'null') {
        if (allowsNull) {
          yield null as T;
        }
        continue;
      }

      final value = converter(entry);
      if (value != null) {
        yield value;
      } else if (allowsNull) {
        yield null as T;
      }
    }
  }

  @override
  DateOnly? getDateOnlyValue() => _parseDateOnlyValue(_decodedValue);

  @override
  DateTime? getDateTimeValue() => _parseDateTimeValue(_decodedValue);

  @override
  double? getDoubleValue() => _parseDoubleValue(_decodedValue);

  @override
  Duration? getDurationValue() => _parseDurationValue(_decodedValue);

  @override
  T? getEnumValue<T extends Enum>(EnumFactory<T> parser) =>
      _parseEnumValue(_decodedValue, parser);

  @override
  // ignore: experimental_member_use
  UuidValue? getGuidValue() => _parseGuidValue(_decodedValue);

  @override
  int? getIntValue() => _parseIntValue(_decodedValue);

  @override
  T? getObjectValue<T extends Parsable>(ParsableFactory<T> factory) {
    final item = factory(this);

    onBeforeAssignFieldValues?.call(item);

    _assignFieldValues(item);

    onAfterAssignFieldValues?.call(item);

    return item;
  }

  void _assignFieldValues<T extends Parsable>(T item) {
    if (_fields.isEmpty) {
      return;
    }

    Map<String, Object>? additionalData;
    if (item case final AdditionalDataHolder dataHolder) {
      dataHolder.additionalData = additionalData ??= {};
    }

    final deserializers = item.getFieldDeserializers();
    for (final field in _fields.entries) {
      final key = field.key;
      final value = field.value;

      if (deserializers.containsKey(key)) {
        final deserializer = deserializers[key]!;

        final node = FormParseNode._fromDecodedValue(value)
          ..onBeforeAssignFieldValues = onBeforeAssignFieldValues
          ..onAfterAssignFieldValues = onAfterAssignFieldValues;

        deserializer.call(node);
      } else if (additionalData != null) {
        if (!additionalData.containsKey(key)) {
          additionalData[key] = value;
        }
      } else {
        throw StateError(
          'Field $key is not defined in the model and no additional data is available',
        );
      }
    }
  }

  @override
  String? getStringValue() => _parseStringValue(_decodedValue);

  @override
  TimeOnly? getTimeOnlyValue() => _parseTimeOnlyValue(_decodedValue);
}
