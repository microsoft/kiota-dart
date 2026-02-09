part of '../microsoft_kiota_serialization_form.dart';

/// Represents a serialization writer that can be used to write a form url
/// encoded string.
class FormSerializationWriter implements SerializationWriter {
  final StringBuffer _buffer = StringBuffer();
  bool writingObject = false;

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
    for (final entry in value.entries) {
      _writeAnyValue(entry.key, entry.value);
    }
  }

  void _writeAnyValue(String? key, Object? value) {
    switch (value) {
      case null:
        writeNullValue(key);
      case final bool b:
        writeBoolValue(key, value: b);
      case final int i:
        writeIntValue(key, i);
      case final double d:
        writeDoubleValue(key, d);
      case final String s:
        writeStringValue(key, s);
      case final DateTime d:
        writeDateTimeValue(key, d);
      case final DateOnly d:
        writeDateOnlyValue(key, d);
      case final TimeOnly t:
        writeTimeOnlyValue(key, t);
      case final Duration d:
        writeDurationValue(key, d);
      // ignore: experimental_member_use
      case final UuidValue u:
        writeUuidValue(key, u);
      default:
        writeStringValue(key, value.toString());
    }
  }

  @override
  void writeBoolValue(String? key, {bool? value}) {
    writeStringValue(key, value?.toString().toLowerCase());
  }

  @override
  void writeByteArrayValue(String? key, Uint8List? value) {
    if (value != null) {
      writeStringValue(key, base64Encode(value));
    }
  }

  @override
  void writeCollectionOfEnumValues<T extends Enum>(
    String? key,
    Iterable<T>? values,
    EnumSerializer<T> serializer,
  ) {
    if (values == null) {
      return;
    }

    StringBuffer? valueNames;
    for (final value in values) {
      if (valueNames == null) {
        valueNames = StringBuffer();
      } else {
        valueNames.write(',');
      }

      valueNames.write(serializer(value));
    }

    writeStringValue(key, valueNames?.toString());
  }

  @override
  void writeCollectionOfObjectValues<T extends Parsable>(
    String? key,
    Iterable<T>? values,
  ) {
    throw UnsupportedError(
      'Form serialization does not support collections of objects.',
    );
  }

  @override
  void writeCollectionOfPrimitiveValues<T>(String? key, Iterable<T>? values) {
    if (values == null) {
      return;
    }

    for (final value in values) {
      if (value != null) {
        _writeAnyValue(key, value);
      }
    }
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
    if (writingObject) {
      throw UnsupportedError(
        'Form serialization does not support nested objects.',
      );
    }

    writingObject = true;

    try {
      if (value == null) {
        return;
      }

      onBeforeObjectSerialization?.call(value);
      onStartObjectSerialization?.call(value, this);

      value.serialize(this);

      if (additionalValuesToMerge != null) {
        for (final additionalValue in additionalValuesToMerge) {
          if (additionalValue != null) {
            onBeforeObjectSerialization?.call(additionalValue);
            onStartObjectSerialization?.call(additionalValue, this);

            additionalValue.serialize(this);

            onAfterObjectSerialization?.call(additionalValue);
          }
        }
      }

      onAfterObjectSerialization?.call(value);
    } finally {
      writingObject = false;
    }
  }

  @override
  void writeStringValue(String? key, String? value) {
    if (key == null || key.isEmpty || value == null || value.isEmpty) {
      return;
    }

    if (_buffer.isNotEmpty) {
      _buffer.write('&');
    }

    _buffer
      ..write(Uri.encodeQueryComponent(key))
      ..write('=')
      ..write(Uri.encodeQueryComponent(value));
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
