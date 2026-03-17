part of '../microsoft_kiota_serialization_form.dart';

/// Represents a [ParseNode] that can be used to parse a form url encoded string.
class FormParseNode implements ParseNode {
  FormParseNode(String value)
    : _rawValue = value,
      _fields = _parseFields(value);

  static Map<String, String> _parseFields(String value) {
    final fields = value.split('&');
    final result = CaseInsensitiveMap<String, List<String>>();

    for (final field in fields) {
      if (field.isEmpty) {
        continue;
      }

      final parts = field.split('=');
      if (parts.length != 2) {
        continue;
      }

      final key = _sanitizeKey(parts[0]);
      final value = _sanitizeValue(parts[1]);

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
  final Map<String, String> _fields;

  String get _decodedValue => Uri.decodeQueryComponent(_rawValue);

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

  static Uint8List? _parseByteArrayValue(String value) {
    if (value.isEmpty) {
      return null;
    }
    return base64Decode(value);
  }

  static DateOnly _parseDateOnlyValue(String value) {
    return DateOnly.fromDateTimeString(value);
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
    if (value.isEmpty) {
      return null;
    }
    // ignore: experimental_member_use
    return UuidValue.withValidation(value);
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

  static TimeOnly _parseTimeOnlyValue(String value) {
    return TimeOnly.fromDateTimeString(value);
  }

  static T? _parseEnumValue<T extends Enum>(
    String value,
    EnumFactory<T> parser,
  ) {
    if (value.isEmpty) {
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

    return FormParseNode(_fields[sanitizedIdentifier]!)
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

  @override
  Iterable<T> getCollectionOfPrimitiveValues<T>() sync* {
    final collection = _decodedValue
        .split(',')
        .where((entry) => entry.isNotEmpty);

    final T? Function(String entry) converter;
    switch (T) {
      case const (bool):
        converter = (v) => _parseBoolValue(v) as T?;
      case const (int):
        converter = (v) => _parseIntValue(v) as T?;
      case const (double):
        converter = (v) => _parseDoubleValue(v) as T?;
      case const (String):
        converter = (v) => _parseStringValue(v) as T?;
      case const (DateTime):
        converter = (v) => _parseDateTimeValue(v) as T?;
      case const (DateOnly):
        converter = (v) => _parseDateOnlyValue(v) as T?;
      case const (TimeOnly):
        converter = (v) => _parseTimeOnlyValue(v) as T?;
      case const (Duration):
        converter = (v) => _parseDurationValue(v) as T?;
      // ignore: experimental_member_use
      case const (UuidValue):
        converter = (v) => _parseGuidValue(v) as T?;
      default:
        throw UnsupportedError('Unsupported primitive type $T');
    }

    for (final entry in collection) {
      final value = converter(entry);
      if (value != null) {
        yield value;
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
        if (value == 'null') {
          continue;
        }

        final deserializer = deserializers[key]!;

        final node = FormParseNode(value)
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
