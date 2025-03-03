part of '../microsoft_kiota_azure.dart';

class AccessToken {
	final String token;
  	final DateTime? expiresOn;
	final DateTime? refreshAt;
	final String tokenType;
  	AccessToken({this.token = '', this.expiresOn = null, this.refreshAt = null, this.tokenType = ''});
}