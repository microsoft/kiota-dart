part of '../microsoft_kiota_azure.dart';

/// Represents the response from the service when requesting a token using a device code.
/// The [accessToken] is the access token that can be used to authenticate requests.
/// The [refreshToken] is the refresh token that can be used to obtain a new access token.
/// The [idToken] is the ID token that can be used to authenticate requests.
/// The [expiresIn] is the time in seconds that the access token is valid.
/// The [tokenType] is the type of the token.
/// The [scope] is the scope of the token. (space separated values)
class DeviceCodeTokenResponse {
  /// Creates a new instance of [DeviceCodeTokenResponse].
  DeviceCodeTokenResponse({
    this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresIn,
    this.tokenType,
    this.scope,
  });

  /// Creates a new instance of [DeviceCodeTokenResponse] from a JSON object.
  factory DeviceCodeTokenResponse.fromJson(Map<String, dynamic> json) {
    return DeviceCodeTokenResponse(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      idToken: json['id_token'] as String?,
      expiresIn: json['expires_in'] as int?,
      tokenType: json['token_type'] as String?,
      scope: json['scope'] as String?,
    );
  }
  final String? accessToken;
  final String? refreshToken;
  final String? idToken;
  final int? expiresIn;
  final String? tokenType;
  final String? scope;
}
