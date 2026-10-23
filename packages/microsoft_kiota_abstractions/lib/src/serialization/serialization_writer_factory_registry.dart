part of '../../microsoft_kiota_abstractions.dart';

/// This factory holds a list of all the registered factories for the various
/// types of nodes.
class SerializationWriterFactoryRegistry implements SerializationWriterFactory {
  static final SerializationWriterFactoryRegistry _defaultInstance =
      SerializationWriterFactoryRegistry();

  /// Default singleton of the registry to be used when registering new
  /// factories that should be available by default.
  static SerializationWriterFactoryRegistry get defaultInstance =>
      _defaultInstance;

  /// List of factories that are registered by content type.
  Map<String, SerializationWriterFactory> contentTypeAssociatedFactories = {};

  @override
  String get validContentType => throw UnsupportedError(
    'The registry supports multiple content types. Get the registered factory instead.',
  );

  @override
  SerializationWriter getSerializationWriter(String contentType) {
    if (contentType.isEmpty) {
      throw ArgumentError('The content type cannot be empty.');
    }

    final vendorSpecificContentType = contentType
        .split(';')
        .where((element) => element.isNotEmpty)
        .first
        .trim();
    if (contentTypeAssociatedFactories.containsKey(vendorSpecificContentType)) {
      return contentTypeAssociatedFactories[vendorSpecificContentType]!
          .getSerializationWriter(vendorSpecificContentType);
    }

    final cleanedContentType = vendorSpecificContentType.replaceAll(
      contentTypeVendorCleanupRegex,
      '',
    );
    if (contentTypeAssociatedFactories.containsKey(cleanedContentType)) {
      return contentTypeAssociatedFactories[cleanedContentType]!
          .getSerializationWriter(cleanedContentType);
    }

    throw UnsupportedError(
      'Content type $cleanedContentType does not have a factory registered to be serialized',
    );
  }
}
