part of '../microsoft_kiota_http.dart';

class KiotaClientFactory {
  KiotaClientFactory._();

  static const String _productName = 'kiota-dart';
  static const String _productVersion = '0.0.8'; // x-release-please-version

  static const _retryCodes = {
    408, // Request Timeout
    429, // Too Many Requests
    500, // Internal Server Error
    502, // Bad Gateway
    503, // Service Unavailable
    504, // Gateway Timeout
  };

  // By common service convention, these status codes mean the server didn't
  // process the request, so resending it is treated as safe for any method.
  static const _unprocessedCodes = {
    429, // Too Many Requests
    503, // Service Unavailable
  };

  /// Creates the default client, which retries transient failures.
  ///
  /// [retryUnprocessedMutationsOnly] controls whether POST and PATCH requests
  /// are retried only after a response showing the server didn't process
  /// them. It defaults to false.
  ///
  /// POST and PATCH aren't idempotent, so resending one the server already
  /// processed can repeat its side effect, such as sending an email twice.
  /// A 408, 500, 502 or 504 can arrive after the server processed the
  /// request. When this is true, POST and PATCH requests are retried only
  /// after a 429 or 503 response, and any other response is returned to the
  /// caller. This relies on the common service convention, followed by
  /// Microsoft Graph, that a 429 or 503 response means the server didn't
  /// process the request. HTTP doesn't guarantee this, so a service that
  /// returns 429 or 503 after acting on a request can still see it repeated.
  /// PUT and DELETE also change state, but they're idempotent, so they aren't
  /// affected, and neither are other methods.
  ///
  /// A POST or PATCH that the client redirected isn't retried, because the
  /// redirect shows the server accepted it. The redirect is detected by
  /// comparing the response's final URL with the request's, so a redirect
  /// chain that ends back at the original URL isn't detected, and a 429 or
  /// 503 at the end of it still allows a retry.
  static http.Client createClient({
    bool retryUnprocessedMutationsOnly = false,
  }) {
    return UserAgentClient(
      retry.RetryClient(
        http.Client(),
        when: (response) => _shouldRetry(
          response,
          retryUnprocessedMutationsOnly: retryUnprocessedMutationsOnly,
        ),
      ),
      userAgent: '$_productName/$_productVersion',
    );
  }

  static bool _shouldRetry(
    http.BaseResponse response, {
    required bool retryUnprocessedMutationsOnly,
  }) {
    if (!_retryCodes.contains(response.statusCode)) {
      return false;
    }
    if (!retryUnprocessedMutationsOnly) {
      return true;
    }
    // A retry resends the original request, even when the client followed a
    // redirect that changed the method, so the original method is the one to
    // check. When the request isn't known, it's treated as a mutation.
    final request = response.request;
    final method = request?.method.toUpperCase();
    if (method != null && method != 'POST' && method != 'PATCH') {
      return true;
    }
    // A followed redirect means the server already accepted the original
    // request, and the status describes the redirected request, not the one a
    // retry would resend.
    if (request != null &&
        response is http.BaseResponseWithUrl &&
        response.url != request.url) {
      return false;
    }
    return _unprocessedCodes.contains(response.statusCode);
  }
}
