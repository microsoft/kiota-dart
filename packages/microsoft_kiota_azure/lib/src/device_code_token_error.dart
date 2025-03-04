part of '../microsoft_kiota_azure.dart';

class DeviceCodeTokenError
{
	DeviceCodeTokenError(
		this.error,
		this.errorDescription,
		this.errorCodes,
		this.timestamp,
		this.traceId,
		this.correlationId,
		this.errorUri
	)
	{
	}
	final String error;
	final String errorDescription;
	final List<String> errorCodes;
	final DateTime timestamp;
	final String traceId;
	final String correlationId;
	final Uri errorUri;
	DeviceCodeTokenError.fromJson(Map<String, dynamic> json) :
		error = json['error'] as String,
		errorDescription = json['error_description'] as String,
		errorCodes = (json['error_codes'] as List).map((e) => e as String).toList(),
		timestamp = DateTime.parse(json['timestamp'] as String),
		traceId = json['trace_id'] as String,
		correlationId = json['correlation_id'] as String,
		errorUri = Uri.parse(json['error_uri'] as String);
}