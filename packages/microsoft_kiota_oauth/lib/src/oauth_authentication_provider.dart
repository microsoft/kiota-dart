part of '../microsoft_kiota_oauth.dart';

/// An authentication provider that uses OAuth to authenticate requests.
class OAuthAuthenticationProvider extends BaseBearerTokenAuthenticationProvider
    implements AuthenticationProvider {
  OAuthAuthenticationProvider(
    OAuthAccessTokenProvider super.accessTokenProvider,
  );
}
