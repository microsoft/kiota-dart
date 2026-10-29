import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:test/test.dart';

void main() {
  group('JsonSerializationWriterFactory', () {
    test('getWriterForJsonContentType', () {
      final factory = JsonSerializationWriterFactory();
      final jsonWriter = factory.getSerializationWriter(
        factory.validContentType,
      );
      expect(jsonWriter, isNotNull);
    });

    test('getSerializationWriter with parameters and whitespace', () {
      final factory = JsonSerializationWriterFactory();

      final writer1 = factory.getSerializationWriter(
        'application/json; charset=utf-8',
      );
      expect(writer1, isNotNull);

      final writer2 = factory.getSerializationWriter(
        '  APPLICATION/JSON; charset=utf-8  ',
      );
      expect(writer2, isNotNull);

      final writer3 = factory.getSerializationWriter(
        'application/json; odata.metadata=minimal',
      );
      expect(writer3, isNotNull);
    });

    test('testThrowsExceptionForInvalidContentType', () {
      const streamContentType = 'application/octet-stream';
      final factory = JsonSerializationWriterFactory();
      expect(
        () => factory.getSerializationWriter(streamContentType),
        throwsArgumentError,
      );
    });
  });
}
