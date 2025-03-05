import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'filter_request.dart';
import 'microsoft_graph_group.dart';
import 'microsoft_graph_user.dart';

String? _httpMethodEnumSerializer(HttpMethod? value) => value?.name;

void main() {
  group('JsonSerializationWriter', () {
    test('writeCollectionOfEnumValues', () {
      final writer = JsonSerializationWriter()
        ..writeCollectionOfEnumValues(
          'key',
          [HttpMethod.get, HttpMethod.post, HttpMethod.patch],
          _httpMethodEnumSerializer,
        );

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals('{"key":["get","post","patch"]}'),
      );
    });
    test('writeCollectionOfPrimitiveValues', () {
      final writer = JsonSerializationWriter()
        ..writeCollectionOfPrimitiveValues(
          'intlist',
          [1, 2, 3],
        );

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
        ..birthDay = DateOnly.fromDateTime(DateTime.parse('2024-10-01 00:00:00'))
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
          'object': const UntypedObject(
            {'name': UntypedString('a name'), 'age': UntypedInteger(8)},
          ),
        };

      final writer = JsonSerializationWriter()
        ..writeObjectValue(
          null,
          simpleUser,
        );

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"id":"abc","createdDateTime":"2023-12-01T15:15:00.000","officeLocation":"at the desk","workDuration":"40:00:00.000000","birthDay":"2024-10-01","heightInMetres":1.7,"startWorkTime":"06:00:00","active":true,"numbers":[2,3,5],"a":"some value","b":12,"c":false,"someNull":"null","untypedArray":["abc",8.8],"object":{"name":"a name","age":8}}',
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

      final writer = JsonSerializationWriter()
        ..writeObjectValue(
          null,
          group,
        );

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"name":"a group","leader":{"heightInMetres":1.9,"endWorkTime":"17:00:00"},"members":[{"officeLocation":"on a chair","workDuration":"2:00:00.000000","a":"#1 coworker"},{"workDuration":"12:00:00.000000","active":true}]}',
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
          'uuid': UuidValue.fromString('019329eb-0ac5-7cc0-9dea-6440b3648264'),
          'user': user2,
        };

      final writer = JsonSerializationWriter()
        ..writeObjectValue(
          null,
          user,
        );

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"workDuration":"2:00:00.000000","a":"#1 coworker","string":"a string","double":0.0,"bool":false,"time":"12:00:00","date":"2000-01-01","datetime":"2024-12-31T23:59:00.000","uuid":"019329eb-0ac5-7cc0-9dea-6440b3648264","user":{"workDuration":"12:00:00.000000","active":true}}',
        ),
      );
    });
    test('writeUntypedNode', () {
      var filterRequest = FilterRequest(
        fieldName: 'name',
        operator: 'contains',
        value: UntypedString('jo'),
      );

      final writer = JsonSerializationWriter()
        ..writeObjectValue(
          null,
          filterRequest,
        );

      expect(
        utf8.decode(writer.getSerializedContent()),
        equals(
          '{"fieldName":"name","operator":"contains","value":"jo"}',
        ),
      );
    });
  });
}
