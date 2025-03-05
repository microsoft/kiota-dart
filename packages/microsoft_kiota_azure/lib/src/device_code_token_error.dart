part of '../microsoft_kiota_azure.dart';

class DeviceCodeTokenError {
  DeviceCodeTokenError(
    this.error,
    this.errorDescription,
    this.errorCodes,
    this.timestamp,
    this.traceId,
    this.correlationId,
    this.errorUri,
  );
  DeviceCodeTokenError.fromJson(Map<String, dynamic> json)
      : error = json['error'] is String ? json['error'] as String : null,
        errorDescription = json['error_description'] is String
            ? json['error_description'] as String
            : null,
        errorCodes = json['error_codes'] is List
            ? (json['error_codes'] as List).map((e) => e as int).toList()
            : null,
        timestamp = json['timestamp'] is String
            ? DateTime.parse(json['timestamp'] as String)
            : null,
        traceId =
            json['trace_id'] is String ? json['trace_id'] as String : null,
        correlationId = json['correlation_id'] is String
            ? json['correlation_id'] as String
            : null,
        errorUri = json['error_uri'] is String
            ? Uri.parse(json['error_uri'] as String)
            : null;
  final String? error;
  final String? errorDescription;
  final List<int>? errorCodes;
  final DateTime? timestamp;
  final String? traceId;
  final String? correlationId;
  final Uri? errorUri;
}
