import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';
import 'package:microsoft_kiota_oauth/microsoft_kiota_oauth.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

Future<void> main() async {
  var client = await oauth2.clientCredentialsGrant(
    authorizationEndpoint,
    identifier,
    secret,
    scopes: ['identify'],
  );

  final accessTokenProvider = OAuthAccessTokenProvider(client: client);
  final authProvider = OAuthAuthenticationProvider(accessTokenProvider);
  final adapter = DefaultRequestAdapter(authProvider: authProvider);
  final apiClient = ApiClient(adapter);
}

class ApiClient {
  final RequestAdapter _adapter;

  ApiClient(this._adapter);
}