part of '../microsoft_kiota_azure.dart';

/// Represents the context for a token request.
/// The scopes are the scopes that the token should have.
/// The claims represent any additional contextual information for the token request. (currently not implemented)
/// The enableCae is a flag to enable the conditional access policy. (currently not implemented)
class TokenRequestContext {
  TokenRequestContext({
    this.scopes = const [],
    this.claims = '',
    this.enableCae = false,
  });
  final List<String> scopes;
  final String claims;
  final bool enableCae;
}
