part of '../microsoft_kiota_serialization_text.dart';

class TextParseNodeFactory implements ParseNodeFactory {
  @override
  ParseNode getRootParseNode(String contentType, Uint8List content) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError('Invalid content type: $contentType');
    }

    final text = utf8.decode(content);

    return TextParseNode(text);
  }

  @override
  String get validContentType => 'text/plain';
}
