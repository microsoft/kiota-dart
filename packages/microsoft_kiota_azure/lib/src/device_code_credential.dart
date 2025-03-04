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
	@override
	Future<AccessToken> getToken(TokenRequestContext requestContext) async {
		final deviceCodeInfo = await _getDeviceCodeInfo(requestContext);
		challengeConsumer(deviceCodeInfo);
		return _pollForToken(deviceCodeInfo);
	}

	Future<DeviceCodeInfo> _getDeviceCodeInfo(TokenRequestContext requestContext) async {
	    final substitutions = <String, dynamic>{};
		substitutions["host"] = host;
		substitutions["tenant_id"] = tenantId;
		substitutions["client_id"] = clientId;
		substitutions["scope"] = requestContext.scopes.join(" ");

		final uri = StdUriTemplate.expand((deviceCodeUriTemplate), substitutions);
			
		final response = await http.get(Uri.parse(uri));
		//TODO use the refresh token if present and not expired
		//TODO cache the access token to avoid re-authenticating across multiple requests
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
		substitutions["client_id"] = clientId;
		substitutions["device_code"] = codeInfo.deviceCode;
		substitutions["grant_type"] = "urn:ietf:params:oauth:grant-type:device_code";

		final uri = StdUriTemplate.expand((tokenUriTemplate), substitutions);
			
		final response = await http.post(Uri.parse(uri));
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