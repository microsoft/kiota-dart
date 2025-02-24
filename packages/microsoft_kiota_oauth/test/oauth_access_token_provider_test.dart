import 'package:microsoft_kiota_oauth/microsoft_kiota_oauth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:test/test.dart';

import 'oauth_access_token_provider_test.mocks.dart';

@GenerateMocks([oauth2.Client])
void main() async {
  test('returns empty string for not-allowed host', () async {
    final client = MockClient();

    final provider = OAuthAccessTokenProvider(
      client: client,
      allowedHosts: ['example.com'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('https://foo.com/me'),
    );

    expect(token, '');
  });

  test('throws for non-https scheme', () async {
    final client = MockClient();

    final provider = OAuthAccessTokenProvider(
      client: client,
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
    final client = MockClient();

    when(client.credentials).thenReturn(oauth2.Credentials('accessToken'));

    final provider = OAuthAccessTokenProvider(
      client: client,
      allowedHosts: ['localhost'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('http://localhost:8080/me'),
    );

    expect(token, 'accessToken');
  });

  test('returns token for allowed host', () async {
    final client = MockClient();

    when(client.credentials).thenReturn(oauth2.Credentials('accessToken'));

    final provider = OAuthAccessTokenProvider(
      client: client,
      allowedHosts: ['example.com'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('https://example.com/me'),
    );

    expect(token, 'accessToken');
  });

  test('refreshes credentials if expired', () async {
    final client = MockClient();

    when(client.credentials).thenReturnInOrder(
      [
        oauth2.Credentials(
          'expired',
          expiration: DateTime.now().subtract(
            const Duration(minutes: 1),
          ),
        ),
        oauth2.Credentials('refreshed'),
      ],
    );

    when(client.refreshCredentials()).thenAnswer((_) async => client);

    final provider = OAuthAccessTokenProvider(
      client: client,
      allowedHosts: ['example.com'],
    );

    final token = await provider.getAuthorizationToken(
      Uri.parse('https://example.com/me'),
    );

    expect(token, 'refreshed');
  });
}
