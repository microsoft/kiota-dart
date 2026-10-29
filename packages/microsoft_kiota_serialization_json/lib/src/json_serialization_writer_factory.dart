part of '../microsoft_kiota_serialization_json.dart';

/// The [SerializationWriterFactory] implementation for JSON content types.
///
/// Content types are normalized to their base media type, allowing optional
/// parameters (such as `charset` or `odata.metadata`) and surrounding whitespace.
class JsonSerializationWriterFactory implements SerializationWriterFactory {
  @override
  SerializationWriter getSerializationWriter(String contentType) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError(
        'The provided content type is not supported by the JsonSerializationWriterFactory: $contentType',
      );
    }

    return JsonSerializationWriter();
  }

  @override
  String get validContentType => 'application/json';
}
