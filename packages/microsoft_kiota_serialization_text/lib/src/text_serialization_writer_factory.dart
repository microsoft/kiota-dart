part of '../microsoft_kiota_serialization_text.dart';

class TextSerializationWriterFactory implements SerializationWriterFactory {
  @override
  SerializationWriter getSerializationWriter(String contentType) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError(
        'The provided content type is not supported by the TextSerializationWriterFactory: $contentType',
      );
    }

    return TextSerializationWriter();
  }

  @override
  String get validContentType => 'text/plain';
}
