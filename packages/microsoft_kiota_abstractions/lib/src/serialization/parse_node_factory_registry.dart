part of '../../microsoft_kiota_abstractions.dart';

/// A regex that matches any sequence of characters that are not a forward slash
/// followed by a plus sign.
///
/// This effectively removes any vendor specific content type information from
/// a content type string.
RegExp contentTypeVendorCleanupRegex = RegExp(r'[^/]+\+');

/// This factory holds a list of all the registered factories for the various
/// types of nodes.
class ParseNodeFactoryRegistry implements ParseNodeFactory {
  static final ParseNodeFactoryRegistry _defaultInstance =
      ParseNodeFactoryRegistry();

  /// Default singleton instance of the registry to be used when registering
  /// new factories that should be available by default.
  static ParseNodeFactoryRegistry get defaultInstance => _defaultInstance;

  /// List of factories that are registered by content type.
  Map<String, ParseNodeFactory> contentTypeAssociatedFactories = {};

  @override
  String get validContentType => throw UnsupportedError(
    'The registry supports multiple content types. Get the registered factory instead.',
  );

  @override
  ParseNode getRootParseNode(String contentType, Uint8List content) {
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
          .getRootParseNode(vendorSpecificContentType, content);
    }

    final cleanedContentType = vendorSpecificContentType.replaceAll(
      contentTypeVendorCleanupRegex,
      '',
    );
    if (contentTypeAssociatedFactories.containsKey(cleanedContentType)) {
      return contentTypeAssociatedFactories[cleanedContentType]!
          .getRootParseNode(cleanedContentType, content);
    }

    throw UnsupportedError(
      'Content type $cleanedContentType does not have a factory registered to be parsed',
    );
  }
}
