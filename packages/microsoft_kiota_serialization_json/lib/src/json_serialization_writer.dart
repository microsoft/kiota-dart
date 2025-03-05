part of '../microsoft_kiota_serialization_json.dart';

class JsonSerializationWriter implements SerializationWriter {
  final Map<String, dynamic> _contents = {};

  final openingObject = '{';
  final closingObject = '}';
  final openingArray = '[';
  final closingArray = ']';
  final separator = ',';

  @override
  ParsableHook? onAfterObjectSerialization;

  @override
  ParsableHook? onBeforeObjectSerialization;

  @override
  void Function(Parsable p, SerializationWriter w)? onStartObjectSerialization;

  @override
  Uint8List getSerializedContent() {
    if (_contents.length == 1 && _contents.keys.first == '') {
      return utf8.encode(jsonEncode(_contents.values.first));
    }
    return utf8.encode(jsonEncode(_contents));
  }

  @override
  void writeAdditionalData(Map<String, dynamic> value) {
    for (final entry in value.entries) {
      if (entry.value is UntypedNode) {
        writeUntypedValue(entry.key, entry.value as UntypedNode);
      } else if (entry.value is DateTime) {
        writeDateTimeValue(entry.key, entry.value as DateTime);
      } else if (entry.value is DateOnly) {
        writeDateOnlyValue(entry.key, entry.value as DateOnly);
      } else if (entry.value is TimeOnly) {
        writeTimeOnlyValue(entry.key, entry.value as TimeOnly);
      } else if (entry.value is Parsable) {
        writeObjectValue(entry.key, entry.value as Parsable);
      } else if (entry.value is UuidValue) {
        writeUuidValue(entry.key, entry.value as UuidValue);
      } else {
        _contents[entry.key] = entry.value;
      }
    }
  }

  @override
  void writeBoolValue(String? key, {bool? value}) {
    if (value != null) {
      _contents[key ?? ''] = value;
    }
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
    if (values == null || values.isEmpty) {
      return;
    } else {
      final enumList = <String?>[];
      for (final value in values) {
        enumList.add(serializer(value));
      }
      _contents[key ?? ''] = enumList;
    }
  }

  @override
  void writeCollectionOfObjectValues<T extends Parsable>(
    String? key,
    Iterable<T>? values,
  ) {
    if (values == null || values.isEmpty) {
      return;
    } else {
      final originalContents = {..._contents};
      _contents.clear();
      final objects = <Map<String, dynamic>>[];
      for (final value in values) {
        value.serialize(this);
        objects.add({..._contents});
        _contents.clear();
      }
      _contents.addAll(originalContents);
      _contents[key ?? ''] = objects;
    }
  }

  @override
  void writeCollectionOfPrimitiveValues<T>(String? key, Iterable<T>? values) {
    if (values == null || values.isEmpty) {
      return;
    } else {
      _contents[key ?? ''] = values;
    }
  }

  @override
  void writeDateTimeValue(String? key, DateTime? value) {
    writeStringValue(key, value?.toIso8601String());
  }

  @override
  void writeDoubleValue(String? key, double? value) {
    if (value != null) {
      _contents[key ?? ''] = value;
    }
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
    if (value != null) {
      _contents[key ?? ''] = value;
    }
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
    if (value == null && additionalValuesToMerge == null) {
      return;
    }
    if (value != null) {
      onBeforeObjectSerialization?.call(value);
    }
    var originalContents = <String, dynamic>{};
    if (key?.isNotEmpty ?? false) {
      originalContents = {..._contents};
      _contents.clear();
    }
    if (value != null) {
      onStartObjectSerialization?.call(value, this);
      if (value is UntypedNode) {
        writeUntypedValue(key, value as UntypedNode);
      } else {
        value.serialize(this);
      }
    }
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
    if (key?.isNotEmpty ?? false) {
      final objectContents = {..._contents};
      _contents
        ..clear()
        ..addAll(originalContents);
      _contents[key ?? ''] = objectContents;
    }
    if (value != null) {
      onAfterObjectSerialization?.call(value);
    }
  }

  @override
  void writeStringValue(String? key, String? value) {
    // if the value is null or empty, we don't write anything
    if (value?.isEmpty ?? true) {
      return;
    }
    _contents[key ?? ''] = value;
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
  void writeUuidValue(String? key, UuidValue? value) {
    writeStringValue(key, value?.uuid);
  }

  void writeUntypedValue(String? key, UntypedNode untypedValue) {
    if (untypedValue is UntypedString) {
      writeStringValue(key, untypedValue.value);
    } else if (untypedValue is UntypedNull) {
      writeNullValue(key);
    } else if (untypedValue is UntypedBoolean) {
      writeBoolValue(key, value: untypedValue.value);
    } else if (untypedValue is UntypedDouble) {
      writeDoubleValue(key, untypedValue.value);
    } else if (untypedValue is UntypedInteger) {
      writeIntValue(key, untypedValue.value);
    } else if (untypedValue is UntypedObject) {
      writeUntypedObject(key, untypedValue);
    } else if (untypedValue is UntypedArray) {
      writeUntypedArray(key, untypedValue);
    }
  }

  void writeUntypedObject(String? key, UntypedObject value) {
    final objectProperties = <String, dynamic>{};
    for (final entry in value.properties.entries) {
      objectProperties[entry.key] = entry.value.getValue();
    }
    _contents[key ?? ''] = objectProperties;
  }

  void writeUntypedArray(String? key, UntypedArray value) {
    final arrayEntries = <dynamic>[];
    for (final entry in value.getValue()) {
      arrayEntries.add(entry.getValue());
    }
    _contents[key ?? ''] = arrayEntries;
  }
}
