part of '../microsoft_kiota_oauth.dart';

class OAuthAccessTokenProvider implements AccessTokenProvider {
  OAuthAccessTokenProvider({
    required this.credentials,
    List<String>? allowedHosts,
    this.scopes,
  }) {
    allowedHostsValidator = AllowedHostsValidator(allowedHosts);
  }

  final OAuthCredentials credentials;
  final List<String>? scopes;

  @override
  late final AllowedHostsValidator allowedHostsValidator;

  @pragma('vm:prefer-inline')
  bool _isLocalhost(Uri uri) {
    return ['localhost', '127.0.0.1', '::1'].contains(uri.host);
  }

  @override
  Future<String> getAuthorizationToken(
    Uri uri, [
    Map<String, Object>? additionalAuthenticationContext,
  ]) async {
    if (!allowedHostsValidator.isUrlHostValid(uri)) {
      return '';
    }

    if (uri.scheme != 'https' && !_isLocalhost(uri)) {
      throw ArgumentError.value(
        uri,
        '$uri',
        'OAuth authentication is only supported for https or localhost',
      );
    }

    final scopes = this.scopes ?? <String>[];
    if (scopes.isEmpty) {
      scopes.add(uri.resolve('/.default').toString());
    }

    // TODO: implement getAuthorizationToken
    throw UnimplementedError();
  }
}

abstract class OAuthCredentials {
  Future<String> getToken({
    required List<String> scopes,
  });
}
