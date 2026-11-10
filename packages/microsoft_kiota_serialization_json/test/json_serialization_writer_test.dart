import 'dart:convert';
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'microsoft_graph_group.dart';
import 'microsoft_graph_user.dart';

String? _httpMethodEnumSerializer(HttpMethod? value) => value?.name;

void main() {
  group('JsonSerializationWriter', () {
    final isoDurations = {
      Duration.zero: 'PT0S',
      const Duration(hours: 2): 'PT2H',
      const Duration(days: 2): 'P2D',
      const Duration(days: 1, hours: 2, minutes: 30): 'P1DT2H30M',
      const Duration(milliseconds: 500): 'PT0.5S',
      const Duration(seconds: 5, microseconds: 123456): 'PT5.123456S',
      const Duration(microseconds: 1): 'PT0.000001S',
      const Duration(minutes: -1): '-PT1M',
      const Duration(microseconds: -1): '-PT0.000001S',
      const Duration(days: -3, hours: -4, seconds: -5): '-P3DT4H5S',
    };
    for (final entry in isoDurations.entries) {
      for (final key in <String?>[null, 'duration']) {
        test('writes and round-trips ${entry.value} at $key', () {
          final writer = JsonSerializationWriter()
            ..writeDurationValue(key, entry.key);
          final serialized = utf8.decode(writer.getSerializedContent());

          expect(
            serialized,
            equals(
              key == null
                  ? '"${entry.value}"'
                  : '{"duration":"${entry.value}"}',
            ),
          );
          final node = JsonParseNode(jsonDecode(serialized));
          expect(
            (key == null ? node : node.getChildNode(key))?.getDurationValue(),
            equals(entry.key),
          );
        });
      }
    }
    test('omits null duration values', () {
      final writer = JsonSerializationWriter()
        ..writeStringValue('sentinel', 'present')
        ..writeDurationValue('duration', null);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('{"sentinel":"present"}'),
      );
    });

    final emptyCollectionWriters =
        <String, void Function(JsonSerializationWriter, String?)>{
          'primitive': (writer, key) =>
              writer.writeCollectionOfPrimitiveValues<int>(key, []),
          'enum': (writer, key) =>
              writer.writeCollectionOfEnumValues<HttpMethod>(
                key,
                [],
                _httpMethodEnumSerializer,
              ),
          'object': (writer, key) =>
              writer.writeCollectionOfObjectValues<MicrosoftGraphUser>(key, []),
        };
    for (final entry in emptyCollectionWriters.entries) {
      for (final key in <String?>[null, 'items']) {
        test('preserves empty ${entry.key} collection at $key', () {
          final writer = JsonSerializationWriter();
          if (key != null) {
            writer.writeStringValue('sentinel', 'present');
          }
          entry.value(writer, key);
          expect(
            jsonDecode(utf8.decode(writer.getSerializedContent())),
            key == null
                ? <Object>[]
                : {'sentinel': 'present', 'items': <Object>[]},
          );
        });
      }
    }
    test('continues to omit null collections', () {
      final writer = JsonSerializationWriter()
        ..writeStringValue('sentinel', 'present')
        ..writeCollectionOfPrimitiveValues<int>('primitive', null)
        ..writeCollectionOfEnumValues<HttpMethod>(
          'enum',
          null,
          _httpMethodEnumSerializer,
        )
        ..writeCollectionOfObjectValues<MicrosoftGraphUser>('object', null);
      expect(jsonDecode(utf8.decode(writer.getSerializedContent())), {
        'sentinel': 'present',
      });
    });
    for (final count in [0, 3]) {
      for (final key in <String?>[null, 'items']) {
        test(
          'serializes a lazy primitive iterable of length $count at $key',
          () {
            final writer = JsonSerializationWriter()
              ..writeCollectionOfPrimitiveValues(
                key,
                Iterable<int>.generate(count),
              );
            final expected = List<int>.generate(count, (index) => index);
            expect(
              jsonDecode(utf8.decode(writer.getSerializedContent())),
              key == null ? expected : {'items': expected},
            );
          },
        );
      }
    }
    test('writeCollectionOfEnumValues', () {
      final writer = JsonSerializationWriter()
        ..writeCollectionOfEnumValues('key', [
          HttpMethod.get,
          HttpMethod.post,
          HttpMethod.patch,
        ], _httpMethodEnumSerializer);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('{"key":["get","post","patch"]}'),
      );
    });
    test('writeCollectionOfPrimitiveValues', () {
      final writer = JsonSerializationWriter()
        ..writeCollectionOfPrimitiveValues('intlist', [1, 2, 3]);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('{"intlist":[1,2,3]}'),
      );
    });

    test('writeObject', () {
      const untypedNodesList = [UntypedString('abc'), UntypedDouble(8.8)];
      final simpleUser = MicrosoftGraphUser()
        ..id = 'abc'
        ..createdDateTime = DateTime(2023, 12, 1, 15, 15)
        ..officeLocation = 'at the desk'
        ..workDuration = const Duration(hours: 40)
        ..birthDay = DateOnly.fromDateTime(
          DateTime.parse('2024-10-01 00:00:00'),
        )
        ..heightInMetres = 1.7
        ..startWorkTime = TimeOnly.fromDateTimeString('06:00')
        ..active = true
        ..numbers = [2, 3, 5]
        ..additionalData = {
          'a': 'some value',
          'b': 12,
          'c': false,
          'someNull': const UntypedNull(),
          'untypedArray': const UntypedArray(untypedNodesList),
          'object': const UntypedObject({
            'name': UntypedString('a name'),
            'age': UntypedInteger(8),
          }),
        };

      final writer = JsonSerializationWriter()
        ..writeObjectValue(null, simpleUser);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"id":"abc","createdDateTime":"2023-12-01T15:15:00.000","officeLocation":"at the desk","workDuration":"P1DT16H","birthDay":"2024-10-01","heightInMetres":1.7,"startWorkTime":"06:00:00","active":true,"numbers":[2,3,5],"a":"some value","b":12,"c":false,"someNull":"null","untypedArray":["abc",8.8],"object":{"name":"a name","age":8}}',
        ),
      );
    });

    test('writeSecondObject', () {
      final user1 = MicrosoftGraphUser()
        ..officeLocation = 'on a chair'
        ..workDuration = const Duration(hours: 2)
        ..additionalData = {'a': '#1 coworker'};
      final user2 = MicrosoftGraphUser()
        ..workDuration = const Duration(hours: 12)
        ..active = true;
      final user3 = MicrosoftGraphUser()
        ..heightInMetres = 1.9
        ..endWorkTime = TimeOnly.fromDateTimeString('17:00');
      final group = MicrosoftGraphGroup()
        ..name = 'a group'
        ..leader = user3
        ..members = [user1, user2];

      final writer = JsonSerializationWriter()..writeObjectValue(null, group);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"name":"a group","leader":{"heightInMetres":1.9,"endWorkTime":"17:00:00"},"members":[{"officeLocation":"on a chair","workDuration":"PT2H","a":"#1 coworker"},{"workDuration":"PT12H","active":true}]}',
        ),
      );
    });

    test('writeAdditionalDataTypes', () {
      final user2 = MicrosoftGraphUser()
        ..workDuration = const Duration(hours: 12)
        ..active = true;
      final user = MicrosoftGraphUser()
        ..officeLocation = ''
        ..workDuration = const Duration(hours: 2)
        ..additionalData = {
          'a': '#1 coworker',
          'string': 'a string',
          'double': 0.0,
          'bool': false,
          'time': TimeOnly.fromComponents(12, 00),
          'date': DateOnly.fromComponents(2000),
          'datetime': DateTime(2024, 12, 31, 23, 59),
          // ignore: experimental_member_use
          'uuid': UuidValue.fromString('019329eb-0ac5-7cc0-9dea-6440b3648264'),
          'user': user2,
        };

      final writer = JsonSerializationWriter()..writeObjectValue(null, user);

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"workDuration":"PT2H","a":"#1 coworker","string":"a string","double":0.0,"bool":false,"time":"12:00:00","date":"2000-01-01","datetime":"2024-12-31T23:59:00.000","uuid":"019329eb-0ac5-7cc0-9dea-6440b3648264","user":{"workDuration":"PT12H","active":true}}',
        ),
      );
    });

    test('round-trip untyped JSON preserves scalar types', () {
      const inputJson =
          '{"int":42,"float":3.14,"str":"hello","numericStr":"123","boolStr":"true","bool":true,"nullVal":null}';
      final parseNode = JsonParseNode(jsonDecode(inputJson));
      final untyped = parseNode.getObjectValue(
        UntypedNode.createFromDiscriminatorValue,
      );

      final writer = JsonSerializationWriter()..writeObjectValue(null, untyped);
      expect(utf8.decode(writer.getSerializedContent()), equals(inputJson));
    });
  });
}
