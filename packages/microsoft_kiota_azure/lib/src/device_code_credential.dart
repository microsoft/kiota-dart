part of '../microsoft_kiota_azure.dart';

/// Implements the [TokenCredential] for device code authentication.
class DeviceCodeCredential implements TokenCredential
{
	static const String deviceCodeUriTemplate = "https://{host}/{tenant_id}/oauth2/v2.0/devicecode{?client_id,scope}";
	static const String tokenUriTemplate = "https://{host}/{tenant_id}/oauth2/v2.0/token{?grant_type,client_id,device_code}";
	static const String defaultTenantId = "common";
	DeviceCodeCredential(
		this.clientId,
		this.challengeConsumer,
		[this.tenantId = defaultTenantId,
		this.host = AzureNationalClouds.PUBLIC_CLOUD]
	)
	{

	}
	final String clientId;
	final String tenantId;
	final String host;
	final void Function(DeviceCodeInfo) challengeConsumer;
	final Map<String, AccessToken> _tokenCache = HashMap<String, AccessToken>();
	@override
	Future<AccessToken> getToken(TokenRequestContext requestContext) async {
		final cachedToken = getCachedToken(requestContext);
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
		_tokenCache[getCacheKey(requestContext)] = token;
	}
	AccessToken? getCachedToken(TokenRequestContext requestContext)
	{
		final cacheKey = getCacheKey(requestContext);
		final cachedToken = _tokenCache[cacheKey];
		if (cachedToken != null) {
			if (cachedToken.expiresOn?.isAfter(DateTime.now()) ?? false) {
				return cachedToken;
			}
			_tokenCache.remove(cacheKey);
		}
		return null;
	}
	String getCacheKey(TokenRequestContext requestContext) => host + clientId + tenantId + requestContext.scopes.join(" ");

	Future<http.Response> postUrlFormBodyRequest(Uri uri, Map<String, String> formBody)
	{
		return http.post(uri,
						headers: {
							"Accept": "application/json",
							"Content-Type": "application/x-www-form-urlencoded"
						},
						body: formBody);
	}
	
	Future<DeviceCodeInfo> _getDeviceCodeInfo(TokenRequestContext requestContext) async {
	    final substitutions = <String, dynamic>{};
		substitutions["host"] = host;
		substitutions["tenant_id"] = tenantId;
		final uri = StdUriTemplate.expand((deviceCodeUriTemplate), substitutions);
			
		final formBody = {
			"client_id" : clientId,
			"scope": requestContext.scopes.join(" ")
		};
		final response = await postUrlFormBodyRequest(Uri.parse(uri), formBody);

		//TODO use the refresh token if present and not expired
		if(response.statusCode != 200) {
			throw Exception("Failed to get device code");
		}
		final responseBody = jsonDecode(response.body);
		return DeviceCodeInfo.fromJson(responseBody);
	}

	Future<AccessToken> _pollForToken(DeviceCodeInfo codeInfo) async
	{
		DeviceCodeTokenResponse? tokenResponse;
		do {
			var interval = codeInfo.interval;
			if (interval <= 0) {
				interval = 3;
			}
			await Future.delayed(Duration(seconds: interval));
			tokenResponse = await _getTokenInformation(codeInfo);
		} while(tokenResponse == null);
		return AccessToken(token: tokenResponse.accessToken, expiresOn: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn)));
		//TODO store the refresh token
	}

	Future<DeviceCodeTokenResponse?> _getTokenInformation(DeviceCodeInfo codeInfo) async
	{
		final substitutions = <String, dynamic>{};
		substitutions["host"] = host;
		substitutions["tenant_id"] = tenantId;

		final uri = StdUriTemplate.expand((tokenUriTemplate), substitutions);

		final formBody = {
			"client_id" : clientId,
			"device_code": codeInfo.deviceCode,
			"grant_type": "urn:ietf:params:oauth:grant-type:device_code"
		};

		final response = await postUrlFormBodyRequest(Uri.parse(uri), formBody);

		if(response.statusCode == 400) {
			final responseBody = jsonDecode(response.body);
			final errorResponse = DeviceCodeTokenError.fromJson(responseBody);
			if (errorResponse.error == "authorization_pending") {
				return null;
			}
			throw Exception("Failed to get token: ${errorResponse.error}");
		}
		final responseBody = jsonDecode(response.body);
		return DeviceCodeTokenResponse.fromJson(responseBody);
	}
}