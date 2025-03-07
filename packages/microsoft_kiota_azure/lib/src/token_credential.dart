part of '../microsoft_kiota_azure.dart';

/// Represents a token credential that can be used to authenticate requests.
/// The [getToken] method is used to obtain an access token for a given request context.
/// The [getToken] method should return a valid access token or throw an exception if the token could not be obtained.
abstract class TokenCredential {
  Future<AccessToken> getToken(TokenRequestContext tokenRequestContext);
}
