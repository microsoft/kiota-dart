part of '../microsoft_kiota_azure.dart';

class DeviceCodeTokenResponse
{
	DeviceCodeTokenResponse.fromJson(Map<String, dynamic> json) :
		accessToken = json['access_token'] as String,
		refreshToken = json['refresh_token'] as String,
		idToken = json['id_token'] as String,
		expiresIn = json['expires_in'] as int,
		tokenType = json['token_type'] as String,
		scope = json['scope'] as String;
	DeviceCodeTokenResponse(
		this.accessToken,
		this.refreshToken,
		this.idToken,
		this.expiresIn,
		this.tokenType,
		this.scope,
	)
;	final String accessToken;
	final String refreshToken;
	final String idToken;
	final int expiresIn;
	final String tokenType;
	final String scope;
}