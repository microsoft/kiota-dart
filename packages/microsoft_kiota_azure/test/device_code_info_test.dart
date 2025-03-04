import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:test/test.dart';
import 'dart:convert';

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
	final deviceCodeInfo = DeviceCodeInfo.fromJson(jsonDecode(json));
	expect(deviceCodeInfo.userCode, 'A62NXK96N');
	expect(deviceCodeInfo.deviceCode, 'foo');
	expect(deviceCodeInfo.verificationUri, Uri.parse('https://microsoft.com/devicelogin'));
	expect(deviceCodeInfo.expiresIn, 900);
	expect(deviceCodeInfo.interval, 5);
	expect(deviceCodeInfo.message, 'To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code A62NXK96N to authenticate.');
  });
}