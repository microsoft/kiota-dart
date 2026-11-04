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
      final existingTokens = existingUserAgent
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();
      final configuredTokens = userAgent
          .trim()
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();
      if (!_containsTokenSequence(existingTokens, configuredTokens)) {
        request.headers[targetKey] = '$existingUserAgent $userAgent';
      }
    }

    return _inner.send(request);
  }

  bool _containsTokenSequence(List<String> source, List<String> target) {
    if (target.isEmpty) {
      return true;
    }
    if (source.length < target.length) {
      return false;
    }
    for (var i = 0; i <= source.length - target.length; i++) {
      var match = true;
      for (var j = 0; j < target.length; j++) {
        if (source[i + j] != target[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        return true;
      }
    }
    return false;
  }
}
