part of '../microsoft_kiota_azure.dart';

class TokenRequestContext
{
	final String tenantId;
	final List<String> scopes;
	final String claims;
	final bool enableCae;
	TokenRequestContext({this.scopes = const [], this.tenantId = 'common', this.claims = '', this.enableCae = false});
}