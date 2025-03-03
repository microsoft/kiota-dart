part of '../microsoft_kiota_azure.dart';

/// Implements the [AccessTokenProvider] using the given [TokenCredential] and
/// allowed hosts.
///
/// Accesses the clients credentials to obtain the access token for requests to
/// allowed domains and refreshes it on-the-fly if expired.
///
/// Throws for requests what are either not using HTTPS or are not to localhost.
///
/// Returns an empty token if the request is to a not-allowed host.
class AzureAccessTokenProvider implements AccessTokenProvider {
  /// Creates a new instance of [AzureAccessTokenProvider] using the given
  /// [credential], [scopes] and [allowedHosts].
  ///
  /// Internally creates a new [AllowedHostsValidator] from the list, which is
  /// then used to validate if a token for any given request should be returned.
  AzureAccessTokenProvider({
    required this.credential,
    this.scopes = const ['https://graph.microsoft.com/.default'],
    List<String>? allowedHosts,
  }) {
    allowedHostsValidator = AllowedHostsValidator(allowedHosts);
  }

  /// The credential to use to obtain the access token and/or refresh credentials.
  final TokenCredential credential;

  final List<String> scopes;

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
        'Azure authentication is only supported for https or localhost',
      );
    }

    //TODO claims and CAE eventually
    final tokenRequestContext = TokenRequestContext(scopes: scopes);

    final token = await credential.getToken(tokenRequestContext);

    return token.token;
  }
}
