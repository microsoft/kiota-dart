import 'package:http/http.dart' as http;
import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';
import 'package:microsoft_kiota_serialization_form/microsoft_kiota_serialization_form.dart';
import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:microsoft_kiota_serialization_multipart/microsoft_kiota_serialization_multipart.dart';
import 'package:microsoft_kiota_serialization_text/microsoft_kiota_serialization_text.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'default_request_adapter_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<AuthenticationProvider>(),
  MockSpec<ParseNodeFactory>(),
  MockSpec<SerializationWriterFactory>(),
])
void main() {
  test('Instantiate DefaultRequestAdapter', () {
    final client = MockClient();
    final authProvider = MockAuthenticationProvider();
    final pNodeFactory = MockParseNodeFactory();
    final sWriterFactory = MockSerializationWriterFactory();

    // Assume no factories are registered prior to calling the constructor
    expect(
      SerializationWriterFactoryRegistry
          .defaultInstance.contentTypeAssociatedFactories,
      isEmpty,
    );

    expect(
      ParseNodeFactoryRegistry.defaultInstance.contentTypeAssociatedFactories,
      isEmpty,
    );

    // This should register the default serializers/deserializers
    final _ = DefaultRequestAdapter(
      authProvider: authProvider,
      pNodeFactory: pNodeFactory,
      sWriterFactory: sWriterFactory,
      client: client,
    );

    final serializers = SerializationWriterFactoryRegistry
        .defaultInstance.contentTypeAssociatedFactories;
    expect(
      serializers,
      containsPair(
        'application/json',
        isA<JsonSerializationWriterFactory>(),
      ),
    );
    expect(
      serializers,
      containsPair(
        'text/plain',
        isA<TextSerializationWriterFactory>(),
      ),
    );
    expect(
      serializers,
      containsPair(
        'application/x-www-form-urlencoded',
        isA<FormSerializationWriterFactory>(),
      ),
    );
    expect(
      serializers,
      containsPair(
        'multipart/form-data',
        isA<MultipartSerializationWriterFactory>(),
      ),
    );

    final deserializers =
        ParseNodeFactoryRegistry.defaultInstance.contentTypeAssociatedFactories;
    expect(
      deserializers,
      containsPair(
        'application/json',
        isA<JsonParseNodeFactory>(),
      ),
    );
    expect(
      deserializers,
      containsPair(
        'text/plain',
        isA<TextParseNodeFactory>(),
      ),
    );
    expect(
      deserializers,
      containsPair(
        'application/x-www-form-urlencoded',
        isA<FormParseNodeFactory>(),
      ),
    );
  });
}
