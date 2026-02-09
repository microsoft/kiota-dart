part of '../microsoft_kiota_serialization_multipart.dart';

class MultipartSerializationWriter implements SerializationWriter {
  final Uint8Buffer _buffer = Uint8Buffer();

  final errorMessagePrefix = 'Multipart serialization does not support writing';

  @override
  ParsableHook? onAfterObjectSerialization;

  @override
  ParsableHook? onBeforeObjectSerialization;

  @override
  void Function(Parsable p1, SerializationWriter p2)?
  onStartObjectSerialization;

  @override
  Uint8List getSerializedContent() {
    return Uint8List.fromList(_buffer);
  }

  @override
  void writeAdditionalData(Map<String, dynamic> value) {
    throw UnsupportedError('$errorMessagePrefix additional data');
  }

  @override
  void writeBoolValue(String? key, {bool? value}) {
    throw UnsupportedError('$errorMessagePrefix boolean values');
  }

  @override
  void writeByteArrayValue(String? key, Uint8List? value) {
    if (value != null) {
      _buffer.addAll(value);
    }
  }

  @override
  void writeCollectionOfEnumValues<T extends Enum>(
    String? key,
    Iterable<T>? values,
    EnumSerializer<T> serializer,
  ) {
    throw UnsupportedError('$errorMessagePrefix collection of enum values');
  }

  @override
  void writeCollectionOfObjectValues<T extends Parsable>(
    String? key,
    Iterable<T>? values,
  ) {
    throw UnsupportedError('$errorMessagePrefix collection of object values');
  }

  @override
  void writeCollectionOfPrimitiveValues<T>(String? key, Iterable<T>? values) {
    throw UnsupportedError(
      '$errorMessagePrefix collection of primitive values',
    );
  }

  @override
  void writeDateOnlyValue(String? key, DateOnly? value) {
    throw UnsupportedError('$errorMessagePrefix date values');
  }

  @override
  void writeDateTimeValue(String? key, DateTime? value) {
    throw UnsupportedError('$errorMessagePrefix date/time values');
  }

  @override
  void writeDoubleValue(String? key, double? value) {
    throw UnsupportedError('$errorMessagePrefix double values');
  }

  @override
  void writeDurationValue(String? key, Duration? value) {
    throw UnsupportedError('$errorMessagePrefix durations');
  }

  @override
  void writeEnumValue<T extends Enum>(
    String? key,
    T? value,
    EnumSerializer<T> serializer,
  ) {
    throw UnsupportedError('$errorMessagePrefix enum values');
  }

  @override
  void writeIntValue(String? key, int? value) {
    throw UnsupportedError('$errorMessagePrefix int values');
  }

  @override
  void writeNullValue(String? key) {
    throw UnsupportedError('$errorMessagePrefix null values');
  }

  @override
  void writeObjectValue<T extends Parsable>(
    String? key,
    T? value, [
    Iterable<Parsable?>? additionalValuesToMerge,
  ]) {
    if (value != null) {
      if (onBeforeObjectSerialization != null) {
        onBeforeObjectSerialization?.call(value);
      }
      if (value is MultipartBody) {
        if (onStartObjectSerialization != null) {
          onStartObjectSerialization?.call(value, this);
        }
        value.serialize(this);
      } else {
        throw Exception(
          'Expected MultipartBody instance but got ${value.runtimeType}',
        );
      }
      if (onAfterObjectSerialization != null) {
        onAfterObjectSerialization?.call(value);
      }
    }
  }

  @override
  void writeStringValue(String? key, String? value) {
    if (key != null && key.isNotEmpty) {
      _buffer.addAll(utf8.encode(key));
    }
    if (value != null && value.isNotEmpty) {
      if (key != null && key.isNotEmpty) {
        _buffer.addAll(utf8.encode(': '));
      }
      _buffer.addAll(utf8.encode(value));
    }
    _buffer.addAll(utf8.encode('\r\n'));
  }

  @override
  void writeTimeOnlyValue(String? key, TimeOnly? value) {
    throw UnsupportedError('$errorMessagePrefix time values');
  }

  @override
  // ignore: experimental_member_use
  void writeUuidValue(String? key, UuidValue? value) {
    throw UnsupportedError('$errorMessagePrefix Uuids');
  }
}
