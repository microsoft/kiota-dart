import 'dart:convert';

import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:test/test.dart';

import './intersection_type_mock.dart';
import 'microsoft_graph_user.dart';
import 'nested_intersection_type.dart';
import 'second_test_entity.dart';
import 'test_enums.dart';

void main() {
  group('JsonParseNode for IntersectionModel', () {
    test('ParsesIntersectionTypeComplexProperty1', () {
      const initialString =
          '{"displayName":"McGill","officeLocation":"Montreal", "id": "opaque"}';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory()
          .getRootParseNode('application/json', rawResponse);
      final result = parseNode
          .getObjectValue(IntersectionTypeMock.createFromDiscriminatorValue);
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNotNull);
        expect(result.composedType2, isNotNull);
        expect(result.composedType3, isNull);
        expect(result.stringValue, isNull);
        expect(result.composedType1!.id, 'opaque');
        expect(result.composedType2!.displayName, 'McGill');
      }
    });

    test('ParsesIntersectionTypeComplexProperty2', () {
      const initialString =
          '{"displayName":"McGill","officeLocation":"Montreal", "id": 10}';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory()
          .getRootParseNode('application/json', rawResponse);
      final result = parseNode
          .getObjectValue(IntersectionTypeMock.createFromDiscriminatorValue);
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNotNull);
        expect(result.composedType2, isNotNull);
        expect(result.composedType3, isNull);
        expect(result.stringValue, isNull);
        expect(result.composedType2!.displayName, 'McGill');
        expect(result.composedType1!.id, isNull);
      }
    });
    test('ParsesIntersectionTypeComplexProperty3', () {
      const initialString =
          '[{"@odata.type":"#microsoft.graph.TestEntity","officeLocation":"Ottawa", "id": "11"}, {"@odata.type":"#microsoft.graph.TestEntity","officeLocation":"Montreal", "id": "10"}]';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory()
          .getRootParseNode('application/json', rawResponse);
      final result = parseNode
          .getObjectValue(IntersectionTypeMock.createFromDiscriminatorValue);
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNull);
        expect(result.composedType2, isNull);
        expect(result.composedType3, isNotNull);
        expect(result.stringValue, isNull);
        expect(result.composedType3?.length, 2);
        expect(result.composedType3?.first.officeLocation, 'Ottawa');
      }
    });
    test('ParsesIntersectionTypeStringValue', () {
      const initialString = '"officeLocation"';
      final rawResponse = utf8.encode(initialString);
      final parseNode = JsonParseNodeFactory()
          .getRootParseNode('application/json', rawResponse);
      final result = parseNode
          .getObjectValue(IntersectionTypeMock.createFromDiscriminatorValue);
      expect(result, isNotNull);
      if (result != null) {
        expect(result.composedType1, isNull);
        expect(result.composedType2, isNull);
        expect(result.composedType3, isNull);
        expect(result.stringValue, 'officeLocation');
      }
    });
    test('SerializeIntersectionTypeStringValue', () {
      final writer = JsonSerializationWriter();
      IntersectionTypeMock()
        ..stringValue = 'officeLocation'
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(result, '"officeLocation"');
    });
    test('SerializeIntersectionTypeComplexProperty1', () {
      final testEntity1 = MicrosoftGraphUser()
        ..officeLocation = 'Montreal'
        ..id = 'opaque';
      final testEntity2 = SecondTestEntity()..displayName = 'McGill';
      final writer = JsonSerializationWriter();
      IntersectionTypeMock()
        ..composedType1 = testEntity1
        ..composedType2 = testEntity2
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(
        result,
        '{"id":"opaque","officeLocation":"Montreal","displayName":"McGill"}',
      );
    });

    test('SerializeIntersectionTypeComplexProperty2', () {
      final testEntity2 = SecondTestEntity()
        ..displayName = 'McGill'
        ..id = 10;
      final writer = JsonSerializationWriter();
      IntersectionTypeMock()
        ..composedType2 = testEntity2
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(result, '{"displayName":"McGill","id":10}');
    });
    test('SerializeIntersectionTypeComplexProperty3', () {
      final testEntity1 = MicrosoftGraphUser()
        ..officeLocation = 'Montreal'
        ..id = '10'
        ..namingEnum = NamingEnum.item2SubItem1;
      final testEntity2 = MicrosoftGraphUser()
        ..officeLocation = 'Ottawa'
        ..id = '11'
        ..namingEnum = NamingEnum.item3SubItem1;
      final writer = JsonSerializationWriter();
      IntersectionTypeMock()
        ..composedType3 = [testEntity1, testEntity2]
        ..serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(
        result,
        '[{"id":"10","namingEnum":"Item2:SubItem1","officeLocation":"Montreal"},{"id":"11","namingEnum":"Item3:SubItem1","officeLocation":"Ottawa"}]',
      );
    });
    test('serializes nested intersection types correctly', () {
      final child = IntersectionTypeMock()..stringValue = 'string';
      final parent = NestedIntersectionType()..nested = child;

      final writer = JsonSerializationWriter();
      parent.serialize(writer);
      final content = writer.getSerializedContent();
      final result = utf8.decode(content);
      expect(result, '{"nested":"string"}');
    });
  });
}
