import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'api_client_builder_test.mocks.dart';

@GenerateMocks([
  SerializationWriter,
  SerializationWriterFactory,
  ParseNodeFactory,
])
void main() {
  const streamContentType = 'application/octet-stream';

  group('ApiClientBuilderTest', () {
    test('enableBackingStoreForSerializationWriterFactory', () {
      final serializationFactoryRegistry = SerializationWriterFactoryRegistry();
      final mockSerializationWriterFactory = MockSerializationWriterFactory();
      serializationFactoryRegistry.contentTypeAssociatedFactories.putIfAbsent(
        streamContentType,
        () => mockSerializationWriterFactory,
      );

      expect(
        serializationFactoryRegistry
                .contentTypeAssociatedFactories[streamContentType]
            is BackingStoreSerializationWriterProxyFactory,
        isFalse,
      );

      // Act
      ApiClientBuilder.enableBackingStoreForSerializationWriterFactory(
        serializationFactoryRegistry,
      );

      // Assert the type has changed due to backing store enabling
      expect(
        serializationFactoryRegistry
            .contentTypeAssociatedFactories[streamContentType],
        isA<BackingStoreSerializationWriterProxyFactory>(),
      );
    });
    test(
      'enableBackingStoreForSerializationWriterFactoryAlsoEnablesForDefaultInstance',
      () {
        final serializationFactoryRegistry =
            SerializationWriterFactoryRegistry();
        final mockSerializationWriterFactory = MockSerializationWriterFactory();
        serializationFactoryRegistry.contentTypeAssociatedFactories.putIfAbsent(
          streamContentType,
          () => mockSerializationWriterFactory,
        );
        SerializationWriterFactoryRegistry
            .defaultInstance
            .contentTypeAssociatedFactories
            .putIfAbsent(
              streamContentType,
              () => mockSerializationWriterFactory,
            );

        expect(
          serializationFactoryRegistry
                  .contentTypeAssociatedFactories[streamContentType]
              is BackingStoreSerializationWriterProxyFactory,
          isFalse,
        );

        // Act
        ApiClientBuilder.enableBackingStoreForSerializationWriterFactory(
          serializationFactoryRegistry,
        );

        // Assert the type has changed due to backing store enabling
        expect(
          serializationFactoryRegistry
              .contentTypeAssociatedFactories[streamContentType],
          isA<BackingStoreSerializationWriterProxyFactory>(),
        );

        expect(
          SerializationWriterFactoryRegistry
              .defaultInstance
              .contentTypeAssociatedFactories[streamContentType],
          isA<BackingStoreSerializationWriterProxyFactory>(),
        );
      },
    );
    test('enableBackingStoreForParseNodeFactory', () {
      final parseNodeRegistry = ParseNodeFactoryRegistry();
      final mockParseNodeFactory = MockParseNodeFactory();
      parseNodeRegistry.contentTypeAssociatedFactories.putIfAbsent(
        streamContentType,
        () => mockParseNodeFactory,
      );
      expect(
        parseNodeRegistry.contentTypeAssociatedFactories[streamContentType]
            is BackingStoreParseNodeFactory,
        isFalse,
      );

      // Act
      ApiClientBuilder.enableBackingStoreForParseNodeFactory(parseNodeRegistry);

      // Assert the type has changed due to backing store enabling
      expect(
        parseNodeRegistry.contentTypeAssociatedFactories[streamContentType],
        isA<BackingStoreParseNodeFactory>(),
      );
    });

    test(
      'enableBackingStoreForParseNodeFactoryAlsoEnablesForDefaultInstance',
      () {
        final parseNodeRegistry = ParseNodeFactoryRegistry();
        final mockParseNodeFactory = MockParseNodeFactory();
        parseNodeRegistry.contentTypeAssociatedFactories.putIfAbsent(
          streamContentType,
          () => mockParseNodeFactory,
        );
        ParseNodeFactoryRegistry.defaultInstance.contentTypeAssociatedFactories
            .putIfAbsent(streamContentType, () => mockParseNodeFactory);

        expect(
          parseNodeRegistry.contentTypeAssociatedFactories[streamContentType]
              is BackingStoreParseNodeFactory,
          isFalse,
        );

        // Act
        ApiClientBuilder.enableBackingStoreForParseNodeFactory(
          parseNodeRegistry,
        );

        // Assert the type has changed due to backing store enabling for the default instance as well.
        expect(
          parseNodeRegistry.contentTypeAssociatedFactories[streamContentType],
          isA<BackingStoreParseNodeFactory>(),
        );
        expect(
          ParseNodeFactoryRegistry
              .defaultInstance
              .contentTypeAssociatedFactories[streamContentType],
          isA<BackingStoreParseNodeFactory>(),
        );
      },
    );
    test(
      'enableBackingStoreForParseNodeFactoryAlsoEnablesForDefaultInstanceMultipleCallsDoesNotDoubleWrap',
      () {
        final parseNodeRegistry = ParseNodeFactoryRegistry();
        final mockParseNodeFactory = MockParseNodeFactory();
        parseNodeRegistry.contentTypeAssociatedFactories.putIfAbsent(
          streamContentType,
          () => mockParseNodeFactory,
        );
        ParseNodeFactoryRegistry.defaultInstance.contentTypeAssociatedFactories
            .putIfAbsent(streamContentType, () => mockParseNodeFactory);

        expect(
          parseNodeRegistry.contentTypeAssociatedFactories[streamContentType]
              is BackingStoreParseNodeFactory,
          isFalse,
        );

        // Act
        final firstResult =
            ApiClientBuilder.enableBackingStoreForParseNodeFactory(
              parseNodeRegistry,
            );
        final secondResult =
            ApiClientBuilder.enableBackingStoreForParseNodeFactory(firstResult);
        final thirdResult =
            ApiClientBuilder.enableBackingStoreForParseNodeFactory(
              secondResult,
            );

        //make sure the original was not modifed
        expect(parseNodeRegistry is BackingStoreParseNodeFactory, isFalse);
        // Assert the type has changed due to backing store enabling
        expect(firstResult, isA<BackingStoreParseNodeFactory>());
        //make sure the second call returned the original wrapper
        expect(firstResult, secondResult);
        expect(firstResult, thirdResult);

        //make sure what is in the registry is a BackingStore, it will be a new object so we can only check the type
        final factory = ParseNodeFactoryRegistry
            .defaultInstance
            .contentTypeAssociatedFactories[streamContentType];
        expect(factory, isA<BackingStoreParseNodeFactory>());
      },
    );
  });
}
