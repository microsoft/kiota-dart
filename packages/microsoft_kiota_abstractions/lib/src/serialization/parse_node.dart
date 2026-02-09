part of '../../microsoft_kiota_abstractions.dart';

/// Interface for a deserialization node in a parse tree. This interface
/// provides an abstraction layer over serialization formats, libraries and
/// implementations.
abstract class ParseNode {
  /// Gets the string value of the node.
  String? getStringValue();

  /// Gets a new parse node for the given identifier.
  ParseNode? getChildNode(String identifier);

  /// Gets the boolean value of the node.
  bool? getBoolValue();

  /// Gets the integer value of the node.
  int? getIntValue();

  /// Gets the double value of the node.
  double? getDoubleValue();

  /// Gets the [UuidValue] value of the node.
  // ignore: experimental_member_use
  UuidValue? getGuidValue();

  /// Gets the [DateTime] value of the node.
  DateTime? getDateTimeValue();

  /// Gets the [DateOnly] value of the node.
  DateOnly? getDateOnlyValue();

  /// Gets the [TimeOnly] value of the node.
  TimeOnly? getTimeOnlyValue();

  /// Gets the [Duration] value of the node.
  Duration? getDurationValue();

  /// Gets the collection of primitive values of the node.
  Iterable<T> getCollectionOfPrimitiveValues<T>();

  /// Gets the collection of enum values of the node.
  Iterable<T> getCollectionOfEnumValues<T extends Enum>(EnumFactory<T> parser);

  /// Gets the collection of model object values of the node.
  Iterable<T> getCollectionOfObjectValues<T extends Parsable>(
    ParsableFactory<T> factory,
  );

  /// Gets the enum value of the node.
  T? getEnumValue<T extends Enum>(EnumFactory<T> parser);

  /// Gets the model object value of the node.
  T? getObjectValue<T extends Parsable>(ParsableFactory<T> factory);

  /// Gets the byte array value of the node.
  Uint8List? getByteArrayValue();

  /// Callback called before the node is deserialized.
  ParsableHook? onBeforeAssignFieldValues;

  /// Callback called after the node is deserialized.
  ParsableHook? onAfterAssignFieldValues;
}
