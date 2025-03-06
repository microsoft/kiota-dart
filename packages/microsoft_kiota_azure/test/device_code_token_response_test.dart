import 'dart:convert';
import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:test/test.dart';

void main() async {
  test('deserializes device token error from json payload', () async {
    const json = '''
		{
			"token_type": "Bearer",
			"scope": "User.Read profile openid email",
			"expires_in": 3599,
			"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5HVEZ2ZEstZnl0aEV1Q...",
			"refresh_token": "AwABAAAAvPM1KaPlrEqdFSBzjqfTGAMxZGUTdM0t4B4...",
			"id_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJhdWQiOiIyZDRkMTFhMi1mODE0LTQ2YTctOD..."
		}
		''';
    final jsonPayload = jsonDecode(json);
    if (jsonPayload is! Map<String, dynamic>) {
      throw Exception('Invalid JSON payload');
    }
    final deviceCodeTokenResponse =
        DeviceCodeTokenResponse.fromJson(jsonPayload);
    expect(
      deviceCodeTokenResponse.accessToken,
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5HVEZ2ZEstZnl0aEV1Q...',
    );
    expect(
      deviceCodeTokenResponse.refreshToken,
      'AwABAAAAvPM1KaPlrEqdFSBzjqfTGAMxZGUTdM0t4B4...',
    );
    expect(
      deviceCodeTokenResponse.idToken,
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJhdWQiOiIyZDRkMTFhMi1mODE0LTQ2YTctOD...',
    );
    expect(deviceCodeTokenResponse.expiresIn, 3599);
    expect(deviceCodeTokenResponse.tokenType, 'Bearer');
    expect(deviceCodeTokenResponse.scope, 'User.Read profile openid email');
  });
}
