part of '../microsoft_kiota_serialization_form.dart';

/// Represents a [ParseNode] that can be used to parse a form url encoded string.
class FormParseNode implements ParseNode {
  FormParseNode(String value)
    : _rawValue = value,
      _fields = _parseFields(value);

  /// Private constructor used when only the raw value is needed (e.g., for
  /// primitive elements in a collection). Avoids the overhead of [_parseFields]
  /// which allocates a map — none of which is needed for a scalar primitive.
  /// The [onBeforeAssignFieldValues] and [onAfterAssignFieldValues] hooks are
  /// intentionally omitted: they are only invoked during [Parsable] object
  /// deserialization and are never called by primitive or enum getters.
  FormParseNode._value(String rawValue)
    : _rawValue = rawValue,
      _fields = const {};

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

  @override
  bool? getBoolValue() {
    final value = _decodedValue;
    if (value.isEmpty) {
      return null;
    }

    return bool.tryParse(value);
  }

  @override
  Uint8List? getByteArrayValue() {
    final value = _decodedValue;

    if (value.isEmpty) {
      return null;
    }

    return base64Decode(value);
  }

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
      final node = FormParseNode._value(entry);

      final enumValue = node.getEnumValue<T>(parser);
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

    final T? Function(FormParseNode node) converter;
    switch (T) {
      case const (bool):
        converter = (node) => node.getBoolValue() as T?;
      case const (int):
        converter = (node) => node.getIntValue() as T?;
      case const (double):
        converter = (node) => node.getDoubleValue() as T?;
      case const (String):
        converter = (node) => node.getStringValue() as T?;
      case const (DateTime):
        converter = (node) => node.getDateTimeValue() as T?;
      case const (DateOnly):
        converter = (node) => node.getDateOnlyValue() as T?;
      case const (TimeOnly):
        converter = (node) => node.getTimeOnlyValue() as T?;
      case const (Duration):
        converter = (node) => node.getDurationValue() as T?;
      // ignore: experimental_member_use
      case const (UuidValue):
        converter = (node) => node.getGuidValue() as T?;
      default:
        throw UnsupportedError('Unsupported primitive type $T');
    }

    for (final entry in collection) {
      final node = FormParseNode._value(entry);

      final value = converter(node);
      if (value != null) {
        yield value;
      }
    }
  }

  @override
  DateOnly? getDateOnlyValue() {
    return DateOnly.fromDateTimeString(_decodedValue);
  }

  @override
  DateTime? getDateTimeValue() {
    return DateTime.tryParse(_decodedValue);
  }

  @override
  double? getDoubleValue() {
    return double.tryParse(_decodedValue);
  }

  @override
  Duration? getDurationValue() {
    return DurationExtensions.tryParse(_decodedValue);
  }

  @override
  T? getEnumValue<T extends Enum>(EnumFactory<T> parser) {
    final value = _decodedValue;
    if (value.isEmpty) {
      return null;
    }

    return parser(value);
  }

  @override
  // ignore: experimental_member_use
  UuidValue? getGuidValue() {
    final value = _decodedValue;
    if (value.isEmpty) {
      return null;
    }

    // ignore: experimental_member_use
    return UuidValue.withValidation(value);
  }

  @override
  int? getIntValue() {
    return int.tryParse(_decodedValue);
  }

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
  String? getStringValue() {
    if (_decodedValue == 'null') {
      return null;
    }

    return _decodedValue;
  }

  @override
  TimeOnly? getTimeOnlyValue() {
    return TimeOnly.fromDateTimeString(_decodedValue);
  }
}
