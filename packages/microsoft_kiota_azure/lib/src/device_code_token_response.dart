part of '../microsoft_kiota_azure.dart';

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
