part of '../microsoft_kiota_azure.dart';

/// Represents the response from the service when requesting a token using a device code.
/// The accessToken is the access token that can be used to authenticate requests.
/// The refreshToken is the refresh token that can be used to obtain a new access token.
/// The idToken is the ID token that can be used to authenticate requests.
/// The expiresIn is the time in seconds that the access token is valid.
/// The tokenType is the type of the token.
/// The scope is the scope of the token. (space separated values)
class DeviceCodeTokenResponse {
  DeviceCodeTokenResponse(
    this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresIn,
    this.tokenType,
    this.scope,
  );
  DeviceCodeTokenResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'] is String
            ? json['access_token'] as String
            : null,
        refreshToken = json['refresh_token'] is String
            ? json['refresh_token'] as String
            : null,
        idToken =
            json['id_token'] is String ? json['id_token'] as String : null,
        expiresIn =
            json['expires_in'] is int ? json['expires_in'] as int : null,
        tokenType =
            json['token_type'] is String ? json['token_type'] as String : null,
        scope = json['scope'] is String ? json['scope'] as String : null;
  final String? accessToken;
  final String? refreshToken;
  final String? idToken;
  final int? expiresIn;
  final String? tokenType;
  final String? scope;
}
