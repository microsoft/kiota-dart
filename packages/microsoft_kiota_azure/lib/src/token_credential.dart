part of '../microsoft_kiota_azure.dart';

/// Represents a token credential that can be used to authenticate requests.
/// The [getToken] method is used to obtain an access token for a given request context.
/// The [getToken] method should return a valid access token or throw an exception if the token could not be obtained.
abstract class TokenCredential {
  /// Returns an [AccessToken] for the given [tokenRequestContext].
  /// The [tokenRequestContext] contains the scopes and claims to use to obtain the token.
  /// The [getToken] method should return a valid access token or throw an exception if the token could not be obtained.
  Future<AccessToken> getToken(TokenRequestContext tokenRequestContext);
}
