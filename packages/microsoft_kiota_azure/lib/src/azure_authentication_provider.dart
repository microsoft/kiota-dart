part of '../microsoft_kiota_azure.dart';

/// An authentication provider that uses an [AzureAccessTokenProvider] to
/// obtain authorization tokens for requests.
class AzureAuthenticationProvider
    extends BaseBearerTokenAuthenticationProvider {
  /// Creates a new instance of [AzureAuthenticationProvider] using the given
  /// [AzureAccessTokenProvider].
  AzureAuthenticationProvider(
    AzureAccessTokenProvider super.accessTokenProvider,
  );

  /// Create a new instance of [AzureAuthenticationProvider] using the given
  /// [credential] and set of [allowedHosts].
  ///
  /// Internally creates a new instance of [AzureAccessTokenProvider].
  factory AzureAuthenticationProvider.withCredential(
    TokenCredential credential, {
    List<String> scopes = const [],
    List<String>? allowedHosts,
  }) {
    return AzureAuthenticationProvider(
      AzureAccessTokenProvider(
        credential: credential,
        scopes: scopes,
        allowedHosts: allowedHosts,
      ),
    );
  }
}
