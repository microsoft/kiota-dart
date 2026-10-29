part of '../microsoft_kiota_serialization_json.dart';

/// The [ParseNodeFactory] implementation for JSON content types.
///
/// Content types are normalized to their base media type, allowing optional
/// parameters (such as `charset` or `odata.metadata`) and surrounding whitespace.
class JsonParseNodeFactory implements ParseNodeFactory {
  @override
  ParseNode getRootParseNode(String contentType, Uint8List content) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final json = utf8.decode(content);
    return JsonParseNode(jsonDecode(json));
  }

  @override
  String get validContentType => 'application/json';
}
