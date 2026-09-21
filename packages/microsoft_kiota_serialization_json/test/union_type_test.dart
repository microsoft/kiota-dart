import 'dart:convert';

import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:test/test.dart';

import 'microsoft_graph_user.dart';
import 'second_test_entity.dart';
import 'union_type_mock.dart';

void main() {
  group('JsonParseNode for UnionModel', () {
    test('ParsesUnionTypeComplexProperty1', () {
      const initialString =
          '{"@odata.type":"#microsoft.graph.testEntity","officeLocation":"Montreal", "id": "opaque"}';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory().getRootParseNode(
        'application/json',
        rawResponse,
      );
      final result = parseNode.getObjectValue(
        UnionTypeMock.createFromDiscriminatorValue,
      );
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNotNull);
        expect(result.composedType2, isNull);
        expect(result.composedType3, isNull);
        expect(result.stringValue, isNull);
        expect(result.composedType1!.id, 'opaque');
        expect(result.composedType1!.officeLocation, 'Montreal');
      }
    });

    test('ParsesUnionTypeComplexProperty2', () {
      const initialString =
          '{"@odata.type":"#microsoft.graph.secondTestEntity","officeLocation":"Montreal", "id": 10}';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory().getRootParseNode(
        'application/json',
        rawResponse,
      );
      final result = parseNode.getObjectValue(
        UnionTypeMock.createFromDiscriminatorValue,
      );
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNull);
        expect(result.composedType2, isNotNull);
        expect(result.composedType3, isNull);
        expect(result.stringValue, isNull);
        expect(result.composedType2!.id, 10);
      }
    });
    test('ParsesUnionTypeComplexProperty3', () {
      const initialString =
          '[{"@odata.type":"#microsoft.graph.TestEntity","officeLocation":"Ottawa", "id": "11"}, {"@odata.type":"#microsoft.graph.TestEntity","officeLocation":"Montreal", "id": "10"}]';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory().getRootParseNode(
        'application/json',
        rawResponse,
      );
      final result = parseNode.getObjectValue(
        UnionTypeMock.createFromDiscriminatorValue,
      );
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNull);
        expect(result.composedType2, isNull);
        expect(result.composedType3, isNotNull);
        expect(result.stringValue, isNull);
        expect(result.composedType3?.length, 2);
        expect(result.composedType3?.first.id, '11');
      }
    });
    test('ParsesUnionTypeStringValue', () {
      const initialString = '"officeLocation"';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory().getRootParseNode(
        'application/json',
        rawResponse,
      );
      final result = parseNode.getObjectValue(
        UnionTypeMock.createFromDiscriminatorValue,
      );
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNull);
        expect(result.composedType2, isNull);
        expect(result.composedType3, isNull);
        expect(result.stringValue, 'officeLocation');
      }
    });
    test('SerializeUnionTypeStringValue', () {
      final writer = JsonSerializationWriter();
      UnionTypeMock()
        ..stringValue = 'officeLocation'
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(result, '"officeLocation"');
    });
    test('SerializeUnionTypeComplexProperty1', () {
      final testEntity1 = MicrosoftGraphUser()
        ..officeLocation = 'Montreal'
        ..id = 'opaque';
      final testEntity2 = SecondTestEntity()..displayName = 'McGill';
      final writer = JsonSerializationWriter();
      UnionTypeMock()
        ..composedType1 = testEntity1
        ..composedType2 = testEntity2
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(result, '{"id":"opaque","officeLocation":"Montreal"}');
    });

    test('SerializeUnionTypeComplexProperty2', () {
      final testEntity2 = SecondTestEntity()
        ..displayName = 'McGill'
        ..id = 10;
      final writer = JsonSerializationWriter();
      UnionTypeMock()
        ..composedType2 = testEntity2
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(result, '{"displayName":"McGill","id":10}');
    });
    test('SerializeUnionComplexProperty3', () {
      final testEntity1 = MicrosoftGraphUser()
        ..officeLocation = 'Montreal'
        ..id = '10';
      final testEntity2 = MicrosoftGraphUser()
        ..officeLocation = 'Ottawa'
        ..id = '11';
      final writer = JsonSerializationWriter();
      UnionTypeMock()
        ..composedType3 = [testEntity1, testEntity2]
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(
        result,
        '[{"id":"10","officeLocation":"Montreal"},{"id":"11","officeLocation":"Ottawa"}]',
      );
    });
  });
}
