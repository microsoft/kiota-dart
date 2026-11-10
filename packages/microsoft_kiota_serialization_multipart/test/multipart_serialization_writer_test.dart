import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:microsoft_kiota_serialization_multipart/microsoft_kiota_serialization_multipart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'multipart_serialization_writer_test.mocks.dart';
import 'test_entity.dart';

String? _httpMethodEnumSerializer(HttpMethod? value) => value?.name;

@GenerateMocks([RequestAdapter])
void main() {
  group('MultipartSerializationWriter', () {
    test('writeEnumValue wich is unsupported', () {
      final writer = MultipartSerializationWriter();
      expect(
        () => writer.writeEnumValue(
          null,
          HttpMethod.get,
          _httpMethodEnumSerializer,
        ),
        throwsUnsupportedError,
      );
    });
    test('writeStringValue', () {
      var writer = MultipartSerializationWriter()
        ..writeStringValue(null, 'value');

      expect(writer.getSerializedContent(), utf8.encode('value\r\n'));

      writer = MultipartSerializationWriter()..writeStringValue('key', 'value');
      expect(writer.getSerializedContent(), utf8.encode('key: value\r\n'));
    });

    test('writeObjectValue', () {
      final binaryData = Uint8List.fromList([0x01, 0x02, 0x03]);

      final requestAdapter = MockRequestAdapter();
      when(
        requestAdapter.serializationWriterFactory,
      ).thenReturn(JsonSerializationWriterFactory());

      final testEntity = TestEntity()
        ..id = '48e31887-5dad-4d73-a9f5-3c356e68a038'
        ..birthDay = DateOnly.fromComponents(1961, 9, 29)
        ..workDuration = const Duration(hours: 8)
        ..startWorkTime = TimeOnly.fromComponents(6, 30)
        ..endWorkTime = TimeOnly.fromComponents(15, 0)
        ..deviceNames = ['device1', 'device2']
        ..additionalData = {
          'mobilePhone': null,
          'jobTitle': 'Author',
          'accountEnabled': false,
          'createdDateTime': DateTime(1961, 9, 29, 8, 31),
          'otherPhones': ['device1', 'device2'],
        };

      final multipartBody = MultipartBody()
        ..requestAdapter = requestAdapter
        ..addOrReplace('testEntity', 'application/json', testEntity)
        ..addOrReplace('image', 'application/octet-stream', binaryData);

      final serializationWriter = MultipartSerializationWriter()
        ..writeObjectValue(null, multipartBody);
      final stringContent = String.fromCharCodes(
        serializationWriter.getSerializedContent(),
      );

      final expected =
          '''
--${multipartBody.boundary}\r
Content-Type: application/json\r
Content-Disposition: form-data; name="testEntity"\r
\r
{"id":"48e31887-5dad-4d73-a9f5-3c356e68a038","birthDay":"1961-09-29","workDuration":"PT8H","startWorkTime":"06:30:00","endWorkTime":"15:00:00","deviceNames":["device1","device2"],"mobilePhone":null,"jobTitle":"Author","accountEnabled":false,"createdDateTime":"1961-09-29T08:31:00.000","otherPhones":["device1","device2"]}\r
--${multipartBody.boundary}\r
Content-Type: application/octet-stream\r
Content-Disposition: form-data; name="image"\r
\r
\u0001\u0002\u0003\r
--${multipartBody.boundary}--\r
''';

      expect(stringContent, expected);
    });
  });
}
