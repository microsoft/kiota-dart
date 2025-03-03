part of '../microsoft_kiota_azure.dart';

abstract class TokenCredential {
  Future<AccessToken> getToken(TokenRequestContext tokenRequestContext);
}