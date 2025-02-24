part of '../microsoft_kiota_oauth.dart';

/// Implements the [AccessTokenProvider] using the given [oauth2.Client] and
/// allowed hosts.
///
/// Accesses the clients credentials to obtain the access token for requests to
/// allowed domains and refreshes it on-the-fly if expired.
///
/// Throws for requests what are either not using HTTPS or are not to localhost.
///
/// Returns an empty token if the request is to a not-allowed host.
class OAuthAccessTokenProvider implements AccessTokenProvider {
  /// Creates a new instance of [OAuthAccessTokenProvider] using the given
  /// [client] and [allowedHosts].
  ///
  /// Internally creates a new [AllowedHostsValidator] from the list, which is
  /// then used to validate if a token for any given request should be returned.
  OAuthAccessTokenProvider({
    required this.client,
    List<String>? allowedHosts,
  }) {
    allowedHostsValidator = AllowedHostsValidator(allowedHosts);
  }

  /// The client to use to obtain the access token and/or refresh credentials.
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
