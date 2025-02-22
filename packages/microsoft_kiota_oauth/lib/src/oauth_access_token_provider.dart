part of '../microsoft_kiota_oauth.dart';

class OAuthAccessTokenProvider implements AccessTokenProvider {
  OAuthAccessTokenProvider({
    required this.client,
    List<String>? allowedHosts,
  }) {
    allowedHostsValidator = AllowedHostsValidator(allowedHosts);
  }

  final oauth2.Client client;

  @override
  late final AllowedHostsValidator allowedHostsValidator;

  @pragma('vm:prefer-inline')
  bool _isLocalhost(Uri uri) {
    return ['localhost', '127.0.0.1', '::1'].contains(uri.host);
  }

  @override
  Future<String> getAuthorizationToken(
    Uri uri, [
    Map<String, Object>? additionalAuthenticationContext,
  ]) async {
    if (!allowedHostsValidator.isUrlHostValid(uri)) {
      return '';
    }

    if (uri.scheme != 'https' && !_isLocalhost(uri)) {
      throw ArgumentError.value(
        uri,
        '$uri',
        'OAuth authentication is only supported for https or localhost',
      );
    }

    if (client.credentials.isExpired) {
      await client.refreshCredentials();
    }

    return client.credentials.accessToken;
  }
}
