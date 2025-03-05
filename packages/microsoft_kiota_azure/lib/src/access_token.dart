part of '../microsoft_kiota_azure.dart';

class AccessToken {
  AccessToken({this.token, this.expiresOn, this.refreshAt, this.tokenType});
  final String? token;
  final DateTime? expiresOn;
  final DateTime? refreshAt;
  final String? tokenType;
}
