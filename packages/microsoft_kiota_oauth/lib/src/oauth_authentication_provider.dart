part of '../microsoft_kiota_oauth.dart';

/// An authentication provider that uses an [OAuthAccessTokenProvider] to
/// obtain authorization tokens for requests.
class OAuthAuthenticationProvider extends BaseBearerTokenAuthenticationProvider
    implements AuthenticationProvider {
  /// Creates a new instance of [OAuthAuthenticationProvider] using the given
  /// [OAuthAccessTokenProvider].
  OAuthAuthenticationProvider(
    OAuthAccessTokenProvider super.accessTokenProvider,
  );

  /// Create a new instance of [OAuthAuthenticationProvider] using the given
  /// [client] and set of [allowedHosts].
  ///
  /// Internally creates a new instance of [OAuthAccessTokenProvider].
  factory OAuthAuthenticationProvider.withClient(
    oauth2.Client client, {
    List<String>? allowedHosts,
  }) {
    return OAuthAuthenticationProvider(
      OAuthAccessTokenProvider(
        client: client,
        allowedHosts: allowedHosts,
      ),
    );
  }
}
