part of '../../microsoft_kiota_abstractions.dart';

/// Defines the contract for serialization of objects to a [Uint8List].
abstract class SerializationWriter {
  /// Writes the specified string value to the buffer with an optional given
  /// [key].
  void writeStringValue(String? key, String? value);

  /// Writes the specified int value to the buffer with an optional given
  /// [key].
  void writeBoolValue(String? key, {bool? value});

  /// Writes the specified int value to the buffer with an optional given
  /// [key].
  void writeIntValue(String? key, int? value);

  /// Writes the specified double value to the buffer with an optional given
  /// [key].
  void writeDoubleValue(String? key, double? value);

  /// Writes the specified [UuidValue] value to the buffer with an optional
  /// given [key].
  // ignore: experimental_member_use
  void writeUuidValue(String? key, UuidValue? value);

  /// Writes the specified [DateTime] value to the buffer with an optional given
  /// [key].
  void writeDateTimeValue(String? key, DateTime? value);

  /// Writes the specified [Duration] value to the buffer with an optional given
  /// [key].
  void writeDurationValue(String? key, Duration? value);

  /// Writes the specified [TimeOnly] value to the buffer with an optional given
  /// [key].
  void writeTimeOnlyValue(String? key, TimeOnly? value);

  /// Writes the specified [DateOnly] value to the buffer with an optional given
  /// [key].
  void writeDateOnlyValue(String? key, DateOnly? value);

  /// Writes a null value for the specified [key].
  void writeNullValue(String? key);

  /// Writes the specified collection of primitive values to the buffer with an
  /// optional given [key].
  void writeCollectionOfPrimitiveValues<T>(String? key, Iterable<T>? values);

  /// Writes the specified collection of [T] object values to the buffer with an
  /// optional given [key].
  void writeCollectionOfObjectValues<T extends Parsable>(
    String? key,
    Iterable<T>? values,
  );

  /// Writes the specified collection of enum [T] values to the buffer with an
  /// optional given [key].
  void writeCollectionOfEnumValues<T extends Enum>(
    String? key,
    Iterable<T>? values,
    EnumSerializer<T> serializer,
  );

  /// Writes the specified byte list as a base64 string to the buffer with an
  /// optional given [key].
  void writeByteArrayValue(String? key, Uint8List? value);

  /// Writes the specified model object to the buffer with an optional given
  /// [key].
  /// The [additionalValuesToMerge] parameter is used to merge additional
  /// values to the main object when serializing an intersection wrapper.
  void writeObjectValue<T extends Parsable>(
    String? key,
    T? value, [
    Iterable<Parsable?>? additionalValuesToMerge,
  ]);

  /// Writes the specified enum value to the buffer with an optional given
  /// [key].
  void writeEnumValue<T extends Enum>(
    String? key,
    T? value,
    EnumSerializer<T> serializer,
  );

  /// Writes the specified additional data to the buffer.
  void writeAdditionalData(Map<String, dynamic> value);

  /// Gets the value of the serialized content.
  Uint8List getSerializedContent();

  /// Callback called before the serialization process starts.
  ParsableHook? onBeforeObjectSerialization;

  /// Callback called after the serialization process ends.
  ParsableHook? onAfterObjectSerialization;

  /// Callback called right after the serialization process starts.
  void Function(Parsable, SerializationWriter)? onStartObjectSerialization;
}
