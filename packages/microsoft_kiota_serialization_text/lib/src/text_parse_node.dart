part of '../microsoft_kiota_serialization_text.dart';

class TextParseNode implements ParseNode {
  TextParseNode(String? text) : _text = _sanitize(text);

  static String? _sanitize(String? text) {
    if (text == null) {
      return null;
    }

    var sanitized = text;

    // trim " characters at beginning and end
    if (sanitized.startsWith('"') && sanitized.endsWith('"')) {
      sanitized = sanitized.substring(1, sanitized.length - 1);
    }

    return sanitized;
  }

  static UnsupportedError _noStructuredDataError() {
    return UnsupportedError('Text does not support structured data');
  }

  final String? _text;

  @override
  ParsableHook? onAfterAssignFieldValues;

  @override
  ParsableHook? onBeforeAssignFieldValues;

  @override
  bool? getBoolValue() {
    return _text == null ? null : bool.tryParse(_text);
  }

  @override
  Uint8List? getByteArrayValue() {
    return _text == null ? null : base64Decode(_text);
  }

  @override
  ParseNode? getChildNode(String identifier) {
    throw _noStructuredDataError();
  }

  @override
  Iterable<T> getCollectionOfEnumValues<T extends Enum>(EnumFactory<T> parser) {
    throw _noStructuredDataError();
  }

  @override
  Iterable<T> getCollectionOfObjectValues<T extends Parsable>(
    ParsableFactory<T> factory,
  ) {
    throw _noStructuredDataError();
  }

  @override
  Iterable<T> getCollectionOfPrimitiveValues<T>() {
    throw _noStructuredDataError();
  }

  @override
  DateOnly? getDateOnlyValue() {
    return _text == null ? null : DateOnly.fromDateTimeString(_text);
  }

  @override
  DateTime? getDateTimeValue() {
    return _text == null ? null : DateTime.tryParse(_text);
  }

  @override
  double? getDoubleValue() {
    return _text == null ? null : double.tryParse(_text);
  }

  @override
  Duration? getDurationValue() {
    return _text == null ? null : DurationExtensions.tryParse(_text);
  }

  @override
  T? getEnumValue<T extends Enum>(EnumFactory<T> parser) {
    if (_text == null || _text.isEmpty) {
      return null;
    }

    return parser(_text);
  }

  @override
  // ignore: experimental_member_use
  UuidValue? getGuidValue() {
    // ignore: experimental_member_use
    return _text == null ? null : UuidValue.withValidation(_text);
  }

  @override
  int? getIntValue() {
    return _text == null ? null : int.tryParse(_text);
  }

  @override
  T? getObjectValue<T extends Parsable>(ParsableFactory<T> factory) {
    throw _noStructuredDataError();
  }

  @override
  String? getStringValue() {
    return _text;
  }

  @override
  TimeOnly? getTimeOnlyValue() {
    return _text == null ? null : TimeOnly.fromDateTimeString(_text);
  }
}
