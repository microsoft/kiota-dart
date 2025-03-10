part of '../microsoft_kiota_azure.dart';

/// Represents the error information returned by the service when requesting a token using a device code.
/// The [error] is the error code returned by the service.
/// The [errorDescription] is a human-readable description of the error.
/// The [errorCodes] is a list of error codes returned by the service.
/// The [timestamp] is the time when the error occurred.
/// The [traceId] is the trace ID of the error.
/// The [correlationId] is the correlation ID of the error.
/// The [errorUri] is the URI of the error.
class DeviceCodeTokenError {
  /// Creates a new instance of [DeviceCodeTokenError].
  DeviceCodeTokenError({
    this.error,
    this.errorDescription,
    this.errorCodes,
    this.timestamp,
    this.traceId,
    this.correlationId,
    this.errorUri,
  });

  /// Creates a new instance of [DeviceCodeTokenError] from a JSON object.
  factory DeviceCodeTokenError.fromJson(Map<String, dynamic> json) {
    return DeviceCodeTokenError(
      error: json['error'] as String?,
      errorDescription: json['error_description'] as String?,
      errorCodes: json['error_codes'] is List
          ? (json['error_codes'] as List).map((e) => e as int).toList()
          : null,
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      traceId: json['trace_id'] as String?,
      correlationId: json['correlation_id'] as String?,
      errorUri: json['error_uri'] is String
          ? Uri.parse(json['error_uri'] as String)
          : null,
    );
  }
  final String? error;
  final String? errorDescription;
  final List<int>? errorCodes;
  final DateTime? timestamp;
  final String? traceId;
  final String? correlationId;
  final Uri? errorUri;
}
