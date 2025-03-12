part of '../microsoft_kiota_azure.dart';

/// Represents the access token response from any credential provider.
/// The [token] is the actual access token.
/// The [expiresOn] is the expiration time of the token.
/// The [refreshAt] is the time when the token should be refreshed.
/// The [tokenType] is the type of the token.
class AccessToken {
  AccessToken({this.token, this.expiresOn, this.refreshAt, this.tokenType});
  final String? token;
  final DateTime? expiresOn;
  final DateTime? refreshAt;
  final String? tokenType;
}
