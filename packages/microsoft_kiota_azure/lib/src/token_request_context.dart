part of '../microsoft_kiota_azure.dart';

class TokenRequestContext {
  TokenRequestContext(
      {this.scopes = const [], this.claims = '', this.enableCae = false});
  final List<String> scopes;
  final String claims;
  final bool enableCae;
}
