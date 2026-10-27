part of '../microsoft_kiota_serialization_form.dart';

/// Represents a serialization writer factory that can be used to create a form
/// url encoded serialization writer.
///
/// Content types are normalized to their base media type, allowing optional
/// parameters (such as `charset`) and surrounding whitespace.
class FormSerializationWriterFactory implements SerializationWriterFactory {
  @override
  SerializationWriter getSerializationWriter(String contentType) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    if (mediaType != validContentType) {
      throw ArgumentError(
        'The provided content type is not supported by the FormSerializationWriterFactory: $contentType',
      );
    }

    return FormSerializationWriter();
  }

  @override
  String get validContentType => 'application/x-www-form-urlencoded';
}
