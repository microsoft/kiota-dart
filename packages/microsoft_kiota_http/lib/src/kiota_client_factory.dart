part of '../microsoft_kiota_http.dart';

class KiotaClientFactory {
  KiotaClientFactory._();

  static const String _productName = 'kiota-dart';
  static const String _productVersion = '0.0.2'; // x-release-please-version

  static http.Client createClient() {
    return UserAgentClient(
      retry.RetryClient(
        http.Client(),
        when: (response) {
          const retryCodes = {
            408, // Request Timeout
            429, // Too Many Requests
            500, // Internal Server Error
            502, // Bad Gateway
            503, // Service Unavailable
            504, // Gateway Timeout
          };

          return retryCodes.contains(response.statusCode);
        },
      ),
      userAgent: '$_productName/$_productVersion',
    );
  }
}
