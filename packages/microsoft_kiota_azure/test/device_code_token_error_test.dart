import 'dart:convert';
import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:test/test.dart';

void main() async {
  test('deserializes device token error from json payload', () async {
    const json = '''
{
		"error": "authorization_pending",
		"error_description": "AADSTS70016: OAuth 2.0 device flow error. Authorization is pending. Continue polling. Trace ID: 9aac4ee6-e730-4929-b3ee-6ea7b67e1d00 Correlation ID: cad65606-26ba-423f-9cab-fdd75756e364 Timestamp: 2025-03-04 17:46:18Z",
		"error_codes": [
			70016
		],
		"timestamp": "2025-03-04 17:46:18Z",
		"trace_id": "9aac4ee6-e730-4929-b3ee-6ea7b67e1d00",
		"correlation_id": "cad65606-26ba-423f-9cab-fdd75756e364",
		"error_uri": "https://login.microsoftonline.com/error?code=70016"
	}''';
    final deviceCodeTokenError =
        DeviceCodeTokenError.fromJson(jsonDecode(json));
    expect(deviceCodeTokenError.error, 'authorization_pending');
    expect(deviceCodeTokenError.errorDescription,
        'AADSTS70016: OAuth 2.0 device flow error. Authorization is pending. Continue polling. Trace ID: 9aac4ee6-e730-4929-b3ee-6ea7b67e1d00 Correlation ID: cad65606-26ba-423f-9cab-fdd75756e364 Timestamp: 2025-03-04 17:46:18Z');
    expect(deviceCodeTokenError.errorCodes, [70016]);
    expect(
        deviceCodeTokenError.timestamp, DateTime.parse('2025-03-04 17:46:18Z'));
    expect(
        deviceCodeTokenError.traceId, '9aac4ee6-e730-4929-b3ee-6ea7b67e1d00');
    expect(deviceCodeTokenError.correlationId,
        'cad65606-26ba-423f-9cab-fdd75756e364');
    expect(deviceCodeTokenError.errorUri,
        Uri.parse('https://login.microsoftonline.com/error?code=70016'));
  });
}
