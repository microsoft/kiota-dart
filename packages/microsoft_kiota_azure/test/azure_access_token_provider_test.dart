import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'azure_access_token_provider_test.mocks.dart';

@GenerateMocks([TokenCredential])
void main() async {
  test('returns empty string for not-allowed host', () async {
    final credential = MockTokenCredential();

    final provider = AzureAccessTokenProvider(
      credential: credential,
      allowedHosts: ['example.com'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('https://foo.com/me'),
    );

    expect(token, '');
  });

  test('throws for non-https scheme', () async {
    final credential = MockTokenCredential();

    final provider = AzureAccessTokenProvider(
      credential: credential,
      allowedHosts: ['example.com'],
    );

    expect(
      () async => provider.getAuthorizationToken(
        Uri.parse('http://example.com/me'),
      ),
      throwsArgumentError,
    );
  });

  test("doesn't throw for localhost and http scheme", () async {
    final credential = MockTokenCredential();

    when(credential.getToken(any)).thenAnswer(
      (_) => Future<AccessToken>.value(AccessToken(token: 'accessToken')),
    );

    final provider = AzureAccessTokenProvider(
      credential: credential,
      allowedHosts: ['localhost'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('http://localhost:8080/me'),
    );

    expect(token, 'accessToken');
  });

  test('returns token for allowed host', () async {
    final credential = MockTokenCredential();

    when(credential.getToken(any)).thenAnswer(
      (_) => Future<AccessToken>.value(AccessToken(token: 'accessToken')),
    );

    final provider = AzureAccessTokenProvider(
      credential: credential,
      allowedHosts: ['example.com'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('https://example.com/me'),
    );

    expect(token, 'accessToken');
  });
}
