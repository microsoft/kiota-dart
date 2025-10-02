part of '../../microsoft_kiota_abstractions.dart';

/// Extension methods for [BaseRequestBuilder].
extension BaseRequestBuilderExtensions<T extends BaseRequestBuilder<T>>
    on BaseRequestBuilder<T> {
  /// Clones the current request builder using [clone] and sets the given
  /// [rawUrl] as the url to use.
  ///
  /// This utilizes the [RequestInformation.rawUrlKey] to store the raw url
  /// in the [pathParameters].
  T withUrl(String rawUrl) =>
      clone()
        ..pathParameters.addOrReplace(RequestInformation.rawUrlKey, rawUrl);
}
