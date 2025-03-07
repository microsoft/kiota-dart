// ignore_for_file: type=lint, unused_local_variable
import 'dart:io';

import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';
import 'package:microsoft_kiota_oauth/microsoft_kiota_oauth.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

Future<void> main() async {
  // choose your authentication flow:
  final client = await authorizationCodeGrant();
  // final client = await clientCredentialsGrant();

  final authProvider = OAuthAuthenticationProvider.withClient(
    client,
    allowedHosts: ['example.com'],
  );
  final adapter = DefaultRequestAdapter(authProvider: authProvider);

  // ... pass adapter to the generated API client
}

final authorizationEndpoint =
    Uri.parse('http://example.com/oauth2/authorization');
final tokenEndpoint = Uri.parse('http://example.com/oauth2/token');
final redirectUrl = Uri.parse('http://my-site.com/oauth2-redirect');

final identifier = '050468627587';
final secret = '331Cxsc6UbFmwtun2kK';

final credentialsFile = File('~/.myapp/credentials.json');

Future<oauth2.Client> clientCredentialsGrant() async {
  return oauth2.clientCredentialsGrant(
    tokenEndpoint,
    identifier,
    secret,
    scopes: ['identify'],
  );
}

Future<oauth2.Client> authorizationCodeGrant() async {
  var exists = await credentialsFile.exists();
  if (exists) {
    final credentialsJson = await credentialsFile.readAsString();
    final credentials = oauth2.Credentials.fromJson(credentialsJson);

    return oauth2.Client(credentials, identifier: identifier, secret: secret);
  }

  final grant = oauth2.AuthorizationCodeGrant(
    identifier,
    tokenEndpoint,
    tokenEndpoint,
    secret: secret,
  );

  final authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

  await redirect(authorizationUrl);
  final responseUrl = await listen(redirectUrl);

  return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
}

Future<void> redirect(Uri url) async {
  throw UnimplementedError();
}

Future<Uri> listen(Uri url) async {
  throw UnimplementedError();
}
