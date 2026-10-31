part of '../microsoft_kiota_serialization_multipart.dart';

/// The [SerializationWriterFactory] implementation for multipart content types.
///
/// Content types are normalized to their base media type, allowing optional
/// parameters (such as `boundary`) and surrounding whitespace.
class MultipartSerializationWriterFactory
    implements SerializationWriterFactory {
  @override
  SerializationWriter getSerializationWriter(String contentType) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError(
        'The provided content type is not supported by the MultipartSerializationWriterFactory: $contentType',
      );
    }

    return MultipartSerializationWriter();
  }

  @override
  String get validContentType => 'multipart/form-data';
}
