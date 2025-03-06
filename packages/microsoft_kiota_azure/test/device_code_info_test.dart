import 'dart:convert';
import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:test/test.dart';

void main() async {
  test('deserializes device info from json payload', () async {
    const json = '''
{
		"user_code": "A62NXK96N",
		"device_code": "foo",
		"verification_uri": "https://microsoft.com/devicelogin",
		"expires_in": 900,
		"interval": 5,
		"message": "To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code A62NXK96N to authenticate."
	}''';
    final jsonPayload = jsonDecode(json);
    if (jsonPayload is! Map<String, dynamic>) {
      throw Exception('Invalid JSON payload');
    }
    final deviceCodeInfo = DeviceCodeInfo.fromJson(jsonPayload);
    expect(deviceCodeInfo.userCode, 'A62NXK96N');
    expect(deviceCodeInfo.deviceCode, 'foo');
    expect(
      deviceCodeInfo.verificationUri,
      Uri.parse('https://microsoft.com/devicelogin'),
    );
    expect(deviceCodeInfo.expiresIn, 900);
    expect(deviceCodeInfo.interval, 5);
    expect(
      deviceCodeInfo.message,
      'To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code A62NXK96N to authenticate.',
    );
  });
}
