part of '../microsoft_kiota_azure.dart';

/// Implements the [TokenCredential] for device code authentication.
/// Provide a [challengeConsumer] function that will be called with the device code information to display to the user.
/// The user will then need to go to the provided URL and enter the code to authenticate.
/// The [clientId] is required and the [tenantId] and [host] are optional.
/// The [tenantId] defaults to 'common' and the [host] defaults to the public Azure cloud.
/// The [_httpClient] is optional and defaults to a new [http.Client], it can be passed to set things like HTTP proxy settings.
class DeviceCodeCredential implements TokenCredential {
  DeviceCodeCredential(
    this.clientId,
    this.challengeConsumer, [
    this.tenantId = defaultTenantId,
    this.host = AzureNationalClouds.publicCloud,
    http.Client? httpClient,
  ]) : _httpClient = httpClient ?? http.Client();
  static const String deviceCodeUriTemplate =
      'https://{host}/{tenant_id}/oauth2/v2.0/devicecode{?client_id,scope}';
  static const String tokenUriTemplate =
      'https://{host}/{tenant_id}/oauth2/v2.0/token{?grant_type,client_id,device_code}';
  static const String defaultTenantId = 'common';
  final String clientId;
  final String tenantId;
  final String host;
  final http.Client _httpClient;
  final void Function(DeviceCodeInfo) challengeConsumer;
  final Map<String, AccessToken> _tokenCache = HashMap<String, AccessToken>();
  @override
  Future<AccessToken> getToken(TokenRequestContext requestContext) async {
    final cachedToken = _getCachedToken(requestContext);
    if (cachedToken != null) {
      return cachedToken;
    }
    final deviceCodeInfo = await _getDeviceCodeInfo(requestContext);
    challengeConsumer(deviceCodeInfo);
    final accessToken = await _pollForToken(deviceCodeInfo);
    addTokenToCache(requestContext, accessToken);
    return accessToken;
  }

  void addTokenToCache(TokenRequestContext requestContext, AccessToken token) {
    _tokenCache[_getCacheKey(requestContext)] = token;
  }

  AccessToken? _getCachedToken(TokenRequestContext requestContext) {
    final cacheKey = _getCacheKey(requestContext);
    final cachedToken = _tokenCache[cacheKey];
    if (cachedToken != null) {
      if (cachedToken.expiresOn?.isAfter(DateTime.now()) ?? false) {
        return cachedToken;
      }
      _tokenCache.remove(cacheKey);
    }
    return null;
  }

  String _getCacheKey(TokenRequestContext requestContext) =>
      host + clientId + tenantId + requestContext.scopes.join(' ');

  Future<http.Response> _postUrlFormBodyRequest(
    Uri uri,
    Map<String, String> formBody,
  ) {
    return _httpClient.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: formBody,
    );
  }

  Future<DeviceCodeInfo> _getDeviceCodeInfo(
    TokenRequestContext requestContext,
  ) async {
    final substitutions = <String, dynamic>{};
    substitutions['host'] = host;
    substitutions['tenant_id'] = tenantId;
    final uri = StdUriTemplate.expand(deviceCodeUriTemplate, substitutions);

    final formBody = {
      'client_id': clientId,
      'scope': requestContext.scopes.join(' '),
    };
    final response = await _postUrlFormBodyRequest(Uri.parse(uri), formBody);

    // TODO(baywet): use the refresh token if present and not expired.
    if (response.statusCode != 200) {
      throw Exception('Failed to get device code');
    }
    final responseBody = jsonDecode(response.body);
    if (responseBody is! Map<String, dynamic>) {
      throw Exception('Failed to parse device code response');
    }
    return DeviceCodeInfo.fromJson(responseBody);
  }

  Future<AccessToken> _pollForToken(DeviceCodeInfo codeInfo) async {
    DeviceCodeTokenResponse? tokenResponse;
    do {
      var interval = codeInfo.interval ?? 0;
      if (interval <= 0) {
        interval = 3;
      }
      await Future<void>.delayed(Duration(seconds: interval));
      tokenResponse = await _getTokenInformation(codeInfo);
    } while (tokenResponse == null);
    return AccessToken(
      token: tokenResponse.accessToken,
      expiresOn:
          DateTime.now().add(Duration(seconds: tokenResponse.expiresIn ?? 60)),
    );
    // TODO(baywet): store the refresh token.
  }

  Future<DeviceCodeTokenResponse?> _getTokenInformation(
    DeviceCodeInfo codeInfo,
  ) async {
    final substitutions = <String, dynamic>{};
    substitutions['host'] = host;
    substitutions['tenant_id'] = tenantId;

    final uri = StdUriTemplate.expand(tokenUriTemplate, substitutions);

    if (codeInfo.deviceCode == null) {
      throw Exception('Device code is null');
    }

    final deviceCode = codeInfo.deviceCode ?? '';

    final formBody = {
      'client_id': clientId,
      'device_code': deviceCode,
      'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
    };

    final response = await _postUrlFormBodyRequest(Uri.parse(uri), formBody);

    if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Failed to parse error response');
      }
      final errorResponse = DeviceCodeTokenError.fromJson(responseBody);
      if (errorResponse.error == 'authorization_pending') {
        return null;
      }
      throw Exception('Failed to get token: ${errorResponse.error}');
    }
    final responseBody = jsonDecode(response.body);
    if (responseBody is! Map<String, dynamic>) {
      throw Exception('Failed to parse token response');
    }
    return DeviceCodeTokenResponse.fromJson(responseBody);
  }
}
