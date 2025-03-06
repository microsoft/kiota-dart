import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:test/test.dart';

void main() async {
  test('gets a token from the device code flow', () async {
    var firstPoll = true;
    final client = MockClient((request) {
      if (request.url.path == '/tenantId/oauth2/v2.0/devicecode') {
        return Future.value(
          http.Response(
            '''
        {
          "user_code": "A62NXK96N",
          "device_code": "foo",
          "verification_uri": "https://microsoft.com/devicelogin",
          "expires_in": 900,
          "interval": 5,
          "message": "To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code A62NXK96N to authenticate."
        }''',
            200,
          ),
        );
      } else if (request.url.path == '/tenantId/oauth2/v2.0/token') {
        if (firstPoll) {
          firstPoll = false;
          return Future.value(
            http.Response(
              '''
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
          }''',
              400,
            ),
          );
        }
        return Future.value(
          http.Response(
            '''
        {
          "token_type": "Bearer",
          "scope": "scope",
          "expires_in": 3600,
          "ext_expires_in": 0,
          "access_token": "accessToken"
        }''',
            200,
          ),
        );
      }
      return Future.value(http.Response('', 404));
    });
    var called = false;
    final credential = DeviceCodeCredential(
      'clientId',
      (deviceCodeInfo) => called = true,
      'tenantId',
      AzureNationalClouds.usGovernment,
      client,
    );
    final accessToken =
        await credential.getToken(TokenRequestContext(scopes: ['scope']));
    expect(called, true);
    expect(accessToken.token, 'accessToken');
  });
}
