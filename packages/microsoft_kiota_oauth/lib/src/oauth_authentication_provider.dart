part of '../microsoft_kiota_oauth.dart';

/// An authentication provider that uses OAuth to authenticate requests.
class OAuthAuthenticationProvider extends BaseBearerTokenAuthenticationProvider
    implements AuthenticationProvider {
  OAuthAuthenticationProvider(
    OAuthAccessTokenProvider super.accessTokenProvider,
  );

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
