import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:microsoft_kiota_serialization_json/src/json_parse_exception.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'derived_microsoft_graph_user.dart';
import 'microsoft_graph_user.dart';
import 'test_enums.dart';
import 'untyped_test_entity.dart';

const _testUserJson = r'''
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",
  "@odata.id": "https://graph.microsoft.com/v2/dcd219dd-bc68-4b9b-bf0b-4a33a796be35/directoryObjects/48d31887-5fad-4d73-a9f5-3c356e68a038/Microsoft.DirectoryServices.User",
  "businessPhones": [
     "+1 412 555 0109"
  ],
  "displayName": "Megan Bowen",
  "namingEnum": "Item2:SubItem1",
  "givenName": "Megan",
  "accountEnabled": true,
  "createdDateTime": "2017-07-29T03:07:25Z",
  "jobTitle": "Auditor",
  "mail": "MeganB@M365x214355.onmicrosoft.com",
  "mobilePhone": null,
  "officeLocation": null,
  "preferredLanguage": "en-US",
  "surname": "Bowen",
  "workDuration": "PT1H",
  "startWorkTime": "08:00:00.0000000",
  "endWorkTime": "17:00:00.0000000",
  "userPrincipalName": "MeganB@M365x214355.onmicrosoft.com",
  "birthDay": "1999-08-07",
  "id": "someId"
}''';

const _testStudentJson = r'''
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",
  "@odata.type": "microsoft.graph.student",
  "@odata.id": "https://graph.microsoft.com/v2/dcd219dd-bc68-4b9b-bf0b-4a33a796be35/directoryObjects/48d31887-5fad-4d73-a9f5-3c356e68a038/Microsoft.DirectoryServices.User",
  "businessPhones": [
    "+1 412 555 0109"
  ],
  "displayName": "Megan Bowen",
  "namingEnum": "Item2:SubItem1",
  "givenName": "Megan",
  "accountEnabled": true,
  "createdDateTime": "2017-07-29T03:07:25Z",
  "jobTitle": "Auditor",
  "mail": "MeganB@M365x214355.onmicrosoft.com",
  "mobilePhone": null,
  "officeLocation": null,
  "preferredLanguage": "en-US",
  "surname": "Bowen",
  "workDuration": "PT1H",
  "startWorkTime": "08:00:00.0000000",
  "endWorkTime": "17:00:00.0000000",
  "userPrincipalName": "MeganB@M365x214355.onmicrosoft.com",
  "birthDay": "2017-09-04",
  "enrolmentDate": "2017-09-04",
  "id": "48d31887-5fad-4d73-a9f5-3c356e68a038"
}''';

const _testUntypedJson = r'''
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#sites('contoso.sharepoint.com')/lists('fa631c4d-ac9f-4884-a7f5-13c659d177e3')/items('1')/fields/$entity",
  "id": "5",
  "title": "Project 101",
  "location": {
    "address": {
      "city": "Redmond",
      "postalCode": "98052",
      "state": "Washington",
      "street": "NE 36th St"
    },
    "coordinates": {
      "latitude": 47.641942,
      "longitude": -122.127222
    },
    "displayName": "Microsoft Building 92",
    "floorCount": 50,
    "hasReception": true,
    "contact": null
  },
  "keywords": [
    {
      "created": "2023-07-26T10:41:26Z",
      "label": "Keyword1",
      "termGuid": "10e9cc83-b5a4-4c8d-8dab-4ada1252dd70",
      "wssId": 6442450942
    },
    {
      "created": "2023-07-26T10:51:26Z",
      "label": "Keyword2",
      "termGuid": "2cae6c6a-9bb8-4a78-afff-81b88e735fef",
      "wssId": 6442450943
    }
  ],
  "detail": null,
  "table": [[1,2,3],[4,5,6],[7,8,9]],
  "extra": {
    "createdDateTime": "2024-01-15T00:00:00\\u002B00:00"
  }
}''';

const _testCollectionOfEnumsJson = '''
[
  "Item2:SubItem1",
  "Item3:SubItem1"
]''';

void main() {
  group('JsonParseNode', () {
    test('Get user object from Json', () {
      final jsonParseNode = JsonParseNode(jsonDecode(_testUserJson));
      final testEntity = jsonParseNode.getObjectValue(
        MicrosoftGraphUser.createFromDiscriminator,
      );

      expect(testEntity, isNotNull);
      if (testEntity != null) {
        expect(testEntity.additionalData, isNotEmpty);
        expect(testEntity.additionalData.containsKey('mobilePhone'), isTrue);
        expect(testEntity.additionalData['jobTitle'], 'Auditor');

        expect(testEntity.officeLocation, null);
        expect(testEntity.id, 'someId');
        expect(testEntity.namingEnum, NamingEnum.item2SubItem1);
        expect(testEntity.workDuration, const Duration(hours: 1));
        expect(testEntity.startWorkTime, TimeOnly.fromComponents(8, 0));
        expect(testEntity.endWorkTime, TimeOnly.fromComponents(17, 0));
        expect(testEntity.createdDateTime, DateTime.utc(2017, 7, 29, 3, 7, 25));
        expect(testEntity.birthDay, DateOnly.fromComponents(1999, 8, 7));
        expect(testEntity.accountEnabled, true);
      }
    });

    test('Get object derived from user', () {
      final jsonParseNode = JsonParseNode(jsonDecode(_testStudentJson));
      final testEntity = jsonParseNode.getObjectValue(
        MicrosoftGraphUser.createFromDiscriminator,
      );
      expect(testEntity, isNotNull);
      if (testEntity is DerivedMicrosoftGraphUser) {
        expect(testEntity.enrolmentDate, DateOnly.fromComponents(2017, 9, 4));
      } else {
        throw ApiException(
          message:
              'Test entity is not of type DerivedMicrosoftGraphUser, but of ${testEntity.runtimeType}',
        );
      }
    });

    test('Get user object from untyped Json', () {
      final jsonParseNode = JsonParseNode(jsonDecode(_testUntypedJson));
      final testEntity = jsonParseNode.getObjectValue(
        UntypedTestEntity.createFromDiscriminator,
      );

      expect(testEntity, isNotNull);
      if (testEntity != null) {
        expect(testEntity.additionalData, isNotEmpty);

        final location = testEntity.location;
        expect(location, isNotNull);
        expect(location is UntypedObject, isTrue);
      }
    });
    test('Get enumcollection from json', () {
      final jsonParseNode = JsonParseNode(
        jsonDecode(_testCollectionOfEnumsJson),
      );
      final testCollection = jsonParseNode.getCollectionOfEnumValues(
        (value) =>
            NamingEnum.values.where((ne) => ne.value == value).firstOrNull,
      );

      expect(testCollection, isNotNull);
      expect(testCollection.length, 2);
      expect(testCollection.first, NamingEnum.item2SubItem1);
      expect(testCollection.last, NamingEnum.item3SubItem1);
    });

    test('Get collection of int (primitive) values from json', () {
      final jsonParseNode = JsonParseNode(jsonDecode('[2,3,5]'));
      final testCollection = jsonParseNode
          .getCollectionOfPrimitiveValues<int>();

      expect(testCollection, isNotNull);
      expect(testCollection.length, 3);
      expect(testCollection.first, 2);
      expect(testCollection.last, 5);
    });

    test('Get collection of DateTime (primitive) values from json', () {
      final jsonParseNode = JsonParseNode(
        jsonDecode('["2025-07-30T23:39:48.101Z"]'),
      );
      final testCollection = jsonParseNode
          .getCollectionOfPrimitiveValues<DateTime>();

      expect(testCollection, isNotNull);
      expect(testCollection.length, 1);
      expect(testCollection.first, DateTime.utc(2025, 7, 30, 23, 39, 48, 101));
    });

    test('Get collection of DateOnly (primitive) values from json', () {
      final jsonParseNode = JsonParseNode(jsonDecode('["2025-07-30"]'));
      final testCollection = jsonParseNode
          .getCollectionOfPrimitiveValues<DateOnly>();

      expect(testCollection, isNotNull);
      expect(testCollection.length, 1);
      expect(testCollection.first, DateOnly.fromComponents(2025, 7, 30));
    });

    test('Get collection of TimeOnly (primitive) values from json', () {
      final jsonParseNode = JsonParseNode(jsonDecode('["23:39:48.101"]'));
      final testCollection = jsonParseNode
          .getCollectionOfPrimitiveValues<TimeOnly>();

      expect(testCollection, isNotNull);
      expect(testCollection.length, 1);
      expect(testCollection.first, TimeOnly.fromComponents(23, 39, 48, 101));
    });

    test('Get collection of Duration (primitive) values from json', () {
      final jsonParseNode = JsonParseNode(jsonDecode('["P4DT12H30M5S"]'));
      final testCollection = jsonParseNode
          .getCollectionOfPrimitiveValues<Duration>();

      expect(testCollection, isNotNull);
      expect(testCollection.length, 1);
      expect(
        testCollection.first,
        const Duration(days: 4, hours: 12, minutes: 30, seconds: 5),
      );
    });

    test('Get collection of UUID (primitive) values from json', () {
      final jsonParseNode = JsonParseNode(
        jsonDecode('["6361d96a-8a4e-4bf5-b3b6-c00a0ea3fa28"]'),
      );
      final testCollection = jsonParseNode
          // ignore: experimental_member_use
          .getCollectionOfPrimitiveValues<UuidValue>();

      expect(testCollection, isNotNull);
      expect(testCollection.length, 1);
      expect(
        testCollection.first,
        // ignore: experimental_member_use
        UuidValue.fromString('6361d96a-8a4e-4bf5-b3b6-c00a0ea3fa28'),
      );
    });

    test('Get collection of primitive values fails for unsupported types', () {
      final jsonParseNode = JsonParseNode(jsonDecode('["foo"]'));

      expect(
        () => jsonParseNode.getCollectionOfPrimitiveValues<Uint8List>(),
        throwsA(
          isA<JsonParseException>().having(
            (e) => e.message,
            'message',
            equals(
              'The type Uint8List is not supported for primitive deserialization',
            ),
          ),
        ),
      );
    });

    test(
      'Get collection of primitive values fails for mixed types (simple)',
      () {
        final jsonParseNode = JsonParseNode(jsonDecode('[0, 1, 2, "foo"]'));

        expect(
          () => jsonParseNode.getCollectionOfPrimitiveValues<int>(),
          throwsA(
            isA<JsonParseException>().having(
              (e) => e.message,
              'message',
              equals(
                'Not every element in the collection of primitives is a int',
              ),
            ),
          ),
        );
      },
    );

    test(
      'Get collection of primitive values fails for mixed types (complex)',
      () {
        final jsonParseNode = JsonParseNode(jsonDecode('["foo", 0]'));

        expect(
          () => jsonParseNode.getCollectionOfPrimitiveValues<DateTime>(),
          throwsA(
            isA<JsonParseException>().having(
              (e) => e.message,
              'message',
              equals(
                'Not every element in the collection of primitives is a String and thus cannot be converted to a DateTime',
              ),
            ),
          ),
        );
      },
    );

    test(
      'Get collection of primitive values throws for invalid values (DateTime)',
      () {
        final jsonParseNode = JsonParseNode(jsonDecode('["foo"]'));

        expect(
          () => jsonParseNode.getCollectionOfPrimitiveValues<DateTime>(),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              equals('Invalid date format'),
            ),
          ),
        );
      },
    );

    test('getBoolValue', () {
      final jsonParseNode = JsonParseNode(jsonDecode('true'));

      expect(jsonParseNode.getBoolValue(), equals(true));
    });

    test('getBoolValue with null', () {
      final jsonParseNode = JsonParseNode(null);

      expect(jsonParseNode.getBoolValue(), equals(null));
    });
    test('getDoubleValue', () {
      final jsonParseNode = JsonParseNode(jsonDecode('1.5'));

      expect(jsonParseNode.getDoubleValue(), equals(1.5));
    });

    test('getDoubleValue with null', () {
      final jsonParseNode = JsonParseNode(null);

      expect(jsonParseNode.getDoubleValue(), equals(null));
    });
    test('getIntValue', () {
      final jsonParseNode = JsonParseNode(jsonDecode('1'));

      expect(jsonParseNode.getIntValue(), equals(1));
    });

    test('getIntValue with null', () {
      final jsonParseNode = JsonParseNode(null);

      expect(jsonParseNode.getIntValue(), equals(null));
    });
  });
}
