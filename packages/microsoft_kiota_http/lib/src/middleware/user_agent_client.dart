part of '../../microsoft_kiota_http.dart';

class UserAgentClient extends http.BaseClient {
  UserAgentClient(this._inner, {required this.userAgent});

  final http.Client _inner;
  final String userAgent;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    String? existingKey;
    for (final key in request.headers.keys) {
      if (key.toLowerCase() == 'user-agent') {
        existingKey = key;
        break;
      }
    }

    final targetKey = existingKey ?? 'User-Agent';
    final existingUserAgent = request.headers[targetKey]?.trim();
    if (existingUserAgent == null || existingUserAgent.isEmpty) {
      request.headers[targetKey] = userAgent;
    } else {
      final tokens = existingUserAgent.split(RegExp(r'\s+'));
      if (!tokens.contains(userAgent)) {
        request.headers[targetKey] = '$existingUserAgent $userAgent';
      }
    }

    return _inner.send(request);
  }
}
