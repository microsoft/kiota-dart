import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'serialization_writer_factory_registry_test.mocks.dart';

@GenerateMocks([SerializationWriter, SerializationWriterFactory])
void main() {
  group('SerializationWriterFactoryRegistry', () {
    test('VendorSpecificContentType', () {
      const contentType = 'application/text';
      final mockWriter = MockSerializationWriter();
      final mockFactory = MockSerializationWriterFactory();
      when(
        mockFactory.getSerializationWriter(contentType),
      ).thenReturn(mockWriter);
      SerializationWriterFactoryRegistry
          .defaultInstance
          .contentTypeAssociatedFactories
          .putIfAbsent(contentType, () => mockFactory);
      final serializationWriter = SerializationWriterFactoryRegistry
          .defaultInstance
          .getSerializationWriter('application/vnd+text');
      expect(serializationWriter, isNotNull);
    });

    test('ContentTypeWithOptionalWhitespace', () {
      const contentType = 'application/json';
      final mockWriter = MockSerializationWriter();
      final mockFactory = MockSerializationWriterFactory();
      when(
        mockFactory.getSerializationWriter(contentType),
      ).thenReturn(mockWriter);
      final registry = SerializationWriterFactoryRegistry();
      registry.contentTypeAssociatedFactories[contentType] = mockFactory;
      final writer = registry.getSerializationWriter(
        'application/json ; charset=utf-8',
      );
      expect(writer, isNotNull);
    });
  });
}
