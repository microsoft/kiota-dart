part of '../microsoft_kiota_azure.dart';

/// Represents the context for a token request.
/// The [scopes] are the scopes that the token should have.
/// The [claims] represent any additional contextual information for the token request. (currently not implemented)
/// The [enableCae] is a flag to enable the conditional access policy. (currently not implemented)
class TokenRequestContext {
  /// Creates a new instance of [TokenRequestContext].
  TokenRequestContext({
    this.scopes = const [],
    this.claims = '',
    this.enableCae = false,
  });

  /// The scopes to use for the token request.
  final List<String> scopes;

  /// The claims to use for the token request.
  final String claims;

  /// The flag to enable the conditional access policy.
  final bool enableCae;
}
