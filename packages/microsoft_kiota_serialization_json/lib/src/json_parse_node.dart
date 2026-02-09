part of '../microsoft_kiota_serialization_json.dart';

/// A helper to get a [Type] from a nullable generic parameter.
typedef _TypeOf<T> = T;

class JsonParseNode implements ParseNode {
  JsonParseNode(this._node);

  final dynamic _node;

  @override
  ParsableHook? onAfterAssignFieldValues;

  @override
  ParsableHook? onBeforeAssignFieldValues;

  @override
  bool? getBoolValue() {
    return _node == null ? null : _node as bool;
  }

  @override
  Uint8List? getByteArrayValue() {
    return _node == null ? null : base64Decode(_node.toString());
  }

  @override
  ParseNode? getChildNode(String identifier) {
    if (_node is Map) {
      final childNode = _node[identifier];
      if (childNode != null) {
        return JsonParseNode(childNode)
          ..onBeforeAssignFieldValues = onBeforeAssignFieldValues
          ..onAfterAssignFieldValues = onAfterAssignFieldValues;
      }
    }

    return null;
  }

  @override
  Iterable<T> getCollectionOfEnumValues<T extends Enum>(
    EnumFactory<T> factory,
  ) {
    final result = <T>[];
    if (_node is List) {
      for (final value in _node) {
        final enumValue = factory(value.toString());
        if (enumValue != null) {
          result.add(enumValue);
        }
      }
    }
    return result;
  }

  @override
  Iterable<T> getCollectionOfObjectValues<T extends Parsable>(
    ParsableFactory<T> factory,
  ) {
    final result = <T>[];
    if (_node is List) {
      for (final value in _node) {
        final node = JsonParseNode(value)
          ..onAfterAssignFieldValues = onAfterAssignFieldValues
          ..onBeforeAssignFieldValues = onBeforeAssignFieldValues;
        final objectValue = node.getObjectValue(factory);
        if (objectValue != null) {
          result.add(objectValue);
        }
      }
    }
    return result;
  }

  /// Checks if [T] is exactly [U] or [U?].
  @pragma('vm:prefer-inline')
  bool _isA<T, U>() => T == U || T == _TypeOf<U?>;

  /// A hacky way to check if [T] is a exactly or a subtype of [U].
  @pragma('vm:prefer-inline')
  bool _isSubtype<T, U>() => <T>[] is List<U>;

  @override
  Iterable<T> getCollectionOfPrimitiveValues<T>() {
    final result = <T>[];
    if (_node case final List<dynamic> items) {
      if (_isA<T, bool>()) {
        return _castPrimitive<T>(items, 'bool');
      } else if (_isA<T, int>()) {
        return _castPrimitive<T>(items, 'int');
      } else if (_isA<T, double>()) {
        return _castPrimitive<T>(items, 'double');
      } else if (_isA<T, String>()) {
        return _castPrimitive<T>(items, 'String');
      } else if (_isA<T, DateTime>()) {
        return _convertPrimitive(
          items,
          (i) => DateTime.parse(i) as T,
          'DateTime',
        );
      } else if (_isSubtype<T, DateOnly?>()) {
        return _convertPrimitive(
          items,
          (i) => DateOnly.fromDateTimeString(i) as T,
          'DateOnly',
        );
      } else if (_isSubtype<T, TimeOnly?>()) {
        return _convertPrimitive(
          items,
          (i) => TimeOnly.fromDateTimeString(i) as T,
          'TimeOnly',
        );
      } else if (_isA<T, Duration>()) {
        return _convertPrimitive(items, (i) {
          final dur = DurationExtensions.tryParse(i);
          if (dur == null) {
            throw JsonParseException(
              message: 'Failed to parse duration: $i',
              node: this,
            );
          }

          return dur as T;
        }, 'Duration');
      } else if (_isA<T, UuidValue>()) {
        return _convertPrimitive(
          items,
          // ignore: experimental_member_use
          (i) => UuidValue.raw(i) as T,
          'UuidValue',
        );
      } else {
        throw JsonParseException(
          message: 'The type $T is not supported for primitive deserialization',
          node: this,
        );
      }
    }

    return result;
  }

  List<T> _castPrimitive<T>(List<dynamic> items, String primitiveName) {
    if (!items.every((i) => i is T)) {
      throw JsonParseException(
        message:
            'Not every element in the collection of primitives is a $primitiveName',
        node: this,
      );
    }

    return items.cast<T>();
  }

  List<T> _convertPrimitive<T>(
    List<dynamic> items,
    T Function(String value) converter,
    String primitiveName,
  ) {
    if (!items.every((i) => i is String)) {
      throw JsonParseException(
        message:
            'Not every element in the collection of primitives is a String and thus cannot be converted to a $primitiveName',
        node: this,
      );
    }

    return items.cast<String>().map(converter).toList();
  }

  @override
  DateOnly? getDateOnlyValue() {
    return _node == null ? null : DateOnly.fromDateTimeString(_node.toString());
  }

  @override
  DateTime? getDateTimeValue() {
    return _node == null ? null : DateTime.tryParse(_node.toString());
  }

  @override
  double? getDoubleValue() {
    return _node == null ? null : double.tryParse(_node.toString());
  }

  @override
  Duration? getDurationValue() {
    return _node == null ? null : DurationExtensions.tryParse(_node.toString());
  }

  @override
  T? getEnumValue<T extends Enum>(EnumFactory<T> parser) {
    return _node == null ? null : parser(_node.toString());
  }

  @override
  // ignore: experimental_member_use
  UuidValue? getGuidValue() {
    // ignore: experimental_member_use
    return _node == null ? null : UuidValue.withValidation(_node.toString());
  }

  @override
  int? getIntValue() {
    return _node == null ? null : int.tryParse(_node.toString());
  }

  @override
  T? getObjectValue<T extends Parsable>(ParsableFactory<T> factory) {
    final item = factory(this);
    if (item is UntypedNode) {
      return getUntypedValue(_node)! as T;
    }

    onBeforeAssignFieldValues?.call(item);
    _assignFieldValues(item);
    onAfterAssignFieldValues?.call(item);

    return item;
  }

  void _assignFieldValues<T extends Parsable>(T item) {
    if (_node is! Map) {
      return;
    }

    onBeforeAssignFieldValues?.call(item);

    final itemAdditionalData = item is AdditionalDataHolder
        ? (item as AdditionalDataHolder).additionalData
        : null;

    final fieldDeserializers = item.getFieldDeserializers();

    for (final entry in _node.entries) {
      if (fieldDeserializers.containsKey(entry.key)) {
        final fieldDeserializer = fieldDeserializers[entry.key];
        if (fieldDeserializer != null) {
          final itemNode = JsonParseNode(entry.value)
            ..onBeforeAssignFieldValues = onBeforeAssignFieldValues
            ..onAfterAssignFieldValues = onAfterAssignFieldValues;
          fieldDeserializer.call(itemNode);
        }
      } else {
        itemAdditionalData?[entry.key as String] = entry.value;
      }
    }
    onAfterAssignFieldValues?.call(item);
  }

  @override
  String? getStringValue() {
    return _node is String ? _node : null;
  }

  @override
  TimeOnly? getTimeOnlyValue() {
    return _node == null ? null : TimeOnly.fromDateTimeString(_node.toString());
  }

  UntypedNode? getUntypedValue(dynamic node) {
    if (node == null) {
      return const UntypedNull();
    }

    if (node is List) {
      final arrayValue = getCollectionOfUntypedValues(node);
      return UntypedArray(arrayValue);
    }

    if (node is Map) {
      final propertiesMap = <String, UntypedNode>{};
      for (final entry in node.entries) {
        final fieldKey = entry.key as String;
        final fieldValue = entry.value;
        final childNode = JsonParseNode(fieldValue)
          ..onBeforeAssignFieldValues = onBeforeAssignFieldValues
          ..onAfterAssignFieldValues = onAfterAssignFieldValues;
        propertiesMap[fieldKey] = childNode.getUntypedValue(fieldValue)!;
      }
      return UntypedObject(propertiesMap);
    }

    final doubleValue = double.tryParse(node.toString());
    if (doubleValue != null) {
      return UntypedDouble(doubleValue);
    }

    final intValue = int.tryParse(node.toString());
    if (intValue != null) {
      return UntypedInteger(intValue);
    }

    final boolValue = bool.tryParse(node.toString());
    if (boolValue != null) {
      return UntypedBoolean(value: boolValue);
    }

    if (node is String) {
      return UntypedString(node);
    }

    throw ArgumentError.value(node, 'node', 'Unable to parse untyped node');
  }

  /// Gets the collection of untyped values of the node.
  Iterable<UntypedNode> getCollectionOfUntypedValues(List<dynamic> nodeArray) {
    final result = <UntypedNode>[];

    nodeArray.forEach((arrayElement) {
      final node = JsonParseNode(arrayElement)
        ..onAfterAssignFieldValues = onAfterAssignFieldValues
        ..onBeforeAssignFieldValues = onBeforeAssignFieldValues;

      final value = node.getUntypedValue(arrayElement);
      if (value != null) {
        result.add(value);
      }
    });

    return result;
  }
}
