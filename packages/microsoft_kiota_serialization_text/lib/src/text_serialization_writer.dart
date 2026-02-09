part of '../microsoft_kiota_serialization_text.dart';

class TextSerializationWriter implements SerializationWriter {
  final StringBuffer _buffer = StringBuffer();
  bool _isFirst = true;

  static UnsupportedError _noStructuredDataError() {
    return UnsupportedError('Text does not support structured data');
  }

  @override
  ParsableHook? onAfterObjectSerialization;

  @override
  ParsableHook? onBeforeObjectSerialization;

  @override
  void Function(Parsable p, SerializationWriter w)? onStartObjectSerialization;

  @override
  Uint8List getSerializedContent() {
    return utf8.encode(_buffer.toString());
  }

  @override
  void writeAdditionalData(Map<String, dynamic> value) {
    throw _noStructuredDataError();
  }

  @override
  void writeBoolValue(String? key, {bool? value}) {
    writeStringValue(key, value?.toString());
  }

  @override
  void writeByteArrayValue(String? key, Uint8List? value) {
    writeStringValue(key, value == null ? null : base64Encode(value));
  }

  @override
  void writeCollectionOfEnumValues<T extends Enum>(
    String? key,
    Iterable<T>? values,
    EnumSerializer<T> serializer,
  ) {
    throw _noStructuredDataError();
  }

  @override
  void writeCollectionOfObjectValues<T extends Parsable>(
    String? key,
    Iterable<T>? values,
  ) {
    throw _noStructuredDataError();
  }

  @override
  void writeCollectionOfPrimitiveValues<T>(String? key, Iterable<T>? values) {
    throw _noStructuredDataError();
  }

  @override
  void writeDateTimeValue(String? key, DateTime? value) {
    writeStringValue(key, value?.toIso8601String());
  }

  @override
  void writeDoubleValue(String? key, double? value) {
    writeStringValue(key, value?.toString());
  }

  @override
  void writeEnumValue<T extends Enum>(
    String? key,
    T? value,
    EnumSerializer<T> serializer,
  ) {
    writeStringValue(key, serializer(value));
  }

  @override
  void writeIntValue(String? key, int? value) {
    writeStringValue(key, value?.toString());
  }

  @override
  void writeNullValue(String? key) {
    writeStringValue(key, 'null');
  }

  @override
  void writeObjectValue<T extends Parsable>(
    String? key,
    T? value, [
    Iterable<Parsable?>? additionalValuesToMerge,
  ]) {
    throw _noStructuredDataError();
  }

  @override
  void writeStringValue(String? key, String? value) {
    // text cannot have keys, so we throw if one is provided
    if (key?.isNotEmpty ?? false) {
      throw _noStructuredDataError();
    }

    // if the value is null or empty, we don't write anything
    if (value?.isEmpty ?? true) {
      return;
    }

    if (!_isFirst) {
      throw UnsupportedError(
        'A value was already written for this serialization writer, text content only supports a single value',
      );
    }

    _isFirst = false;
    _buffer.write(value);
  }

  @override
  void writeDateOnlyValue(String? key, DateOnly? value) {
    writeStringValue(key, value?.toRfc3339String());
  }

  @override
  void writeDurationValue(String? key, Duration? value) {
    writeStringValue(key, value?.toString());
  }

  @override
  void writeTimeOnlyValue(String? key, TimeOnly? value) {
    writeStringValue(key, value?.toRfc3339String());
  }

  @override
  // ignore: experimental_member_use
  void writeUuidValue(String? key, UuidValue? value) {
    writeStringValue(key, value?.uuid);
  }
}
