import 'package:microsoft_kiota_serialization_multipart/microsoft_kiota_serialization_multipart.dart';
import 'package:test/test.dart';

void main() {
  group('MultipartSerializationWriterFactory', () {
    test('getWriterForMultipartContentType', () {
      final factory = MultipartSerializationWriterFactory();
      final writer = factory.getSerializationWriter(factory.validContentType);
      expect(writer, isNotNull);
    });

    test('getSerializationWriter with parameters and whitespace', () {
      final factory = MultipartSerializationWriterFactory();

      final writer1 = factory.getSerializationWriter(
        'multipart/form-data; boundary=---------------------------974767299852498929531610575',
      );
      expect(writer1, isNotNull);

      final writer2 = factory.getSerializationWriter(
        '  MULTIPART/FORM-DATA; boundary=something  ',
      );
      expect(writer2, isNotNull);

      final writer3 = factory.getSerializationWriter(
        'multipart/form-data; charset=utf-8; boundary=something',
      );
      expect(writer3, isNotNull);
    });

    test('testThrowsExceptionForInvalidContentType', () {
      const streamContentType = 'application/octet-stream';
      final factory = MultipartSerializationWriterFactory();
      expect(
        () => factory.getSerializationWriter(streamContentType),
        throwsArgumentError,
      );
    });
  });
}
