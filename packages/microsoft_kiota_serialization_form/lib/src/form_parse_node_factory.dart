part of '../microsoft_kiota_serialization_form.dart';

/// The [ParseNodeFactory] implementation for form content types.
///
/// Content types are normalized to their base media type, allowing optional
/// parameters (such as `charset`) and surrounding whitespace.
class FormParseNodeFactory implements ParseNodeFactory {
  @override
  ParseNode getRootParseNode(String contentType, Uint8List content) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final text = utf8.decode(content);

    return FormParseNode(text);
  }

  @override
  String get validContentType => 'application/x-www-form-urlencoded';
}
