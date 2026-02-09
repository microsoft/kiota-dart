part of '../microsoft_kiota_abstractions.dart';

/// This class represents an abstract HTTP request.
class RequestInformation {
  /// Creates a new instance of [RequestInformation].
  RequestInformation({
    this.httpMethod,
    this.urlTemplate,
    Map<String, dynamic>? pathParameters,
  }) : queryParameters = CaseInsensitiveMap(),
       pathParameters = CaseInsensitiveMap() {
    if (pathParameters != null) {
      this.pathParameters.addAll(pathParameters);
    }
  }

  /// The key for the raw request url, which overrides the base url.
  static const rawUrlKey = 'request-raw-url';

  /// The URL template for the current request.
  String? urlTemplate;

  /// The path parameters to use for the URL template when generating the URI.
  PathParameters pathParameters;

  /// The HTTP [HttpMethod] of the request.
  HttpMethod? httpMethod;

  /// The query parameters to use for the URL when generating the URI.
  QueryParameters queryParameters;

  final HttpHeaders _headers = HttpHeaders();

  /// The request headers.
  HttpHeaders get headers => _headers;

  /// The request body.
  Uint8List? content;

  final Map<String, RequestOption> _requestOptions = {};

  /// The request options.
  Iterable<RequestOption> get requestOptions => _requestOptions.values;

  Uri? _rawUri;

  /// The URI of the request.
  Uri get uri {
    if (_rawUri != null) {
      return _rawUri!;
    }

    if (pathParameters.containsKey(rawUrlKey) &&
        pathParameters[rawUrlKey] is String) {
      uri = Uri.parse(pathParameters[rawUrlKey] as String);

      return _rawUri!;
    }

    final url = urlTemplate;
    if (url == null) {
      throw ArgumentError('urlTemplate');
    }

    if (url.contains('{+baseurl}') && !pathParameters.containsKey('baseurl')) {
      throw ArgumentError(
        'pathParameters must contain a value for "baseurl" for the url to be built.',
      );
    }

    final substitutions = <String, dynamic>{};
    for (final urlTemplateParameter in pathParameters.entries) {
      substitutions[urlTemplateParameter.key] = _getSanitizedValue(
        urlTemplateParameter.value,
      );
    }

    for (final queryStringParameter in queryParameters.entries) {
      if (queryStringParameter.value != null) {
        substitutions[queryStringParameter.key] = _getSanitizedValue(
          queryStringParameter.value,
        );
      }
    }

    return Uri.parse(StdUriTemplate.expand(url, substitutions));
  }

  /// Sets the URI of the request.
  set uri(Uri value) {
    queryParameters.clear();
    pathParameters.clear();
    _rawUri = value;
  }

  static dynamic _getSanitizedValue(dynamic value) {
    if (value is bool) {
      return value.toString().toLowerCase();
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    // ignore: experimental_member_use
    if (value is UuidValue) {
      return value.toFormattedString();
    }

    if (value is TimeOnly) {
      return value.toRfc3339String();
    }

    if (value is DateOnly) {
      return value.toRfc3339String();
    }

    if (value is Enum) {
      return value.name;
    }

    if (value is List) {
      return value.map(_getSanitizedValue).toList(growable: false);
    }

    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(_getSanitizedValue(k), _getSanitizedValue(v)),
      );
    }

    return value;
  }

  /// Adds a collection of request options to the request.
  void addRequestOptions(Iterable<RequestOption> options) {
    for (final option in options) {
      _requestOptions.addOrReplace(option.runtimeType.toString(), option);
    }
  }

  /// Removes a collection of request options from the request.
  void removeRequestOptions(Iterable<RequestOption> options) {
    for (final option in options) {
      _requestOptions.remove(option.runtimeType.toString());
    }
  }

  /// Gets a [RequestOption] of the specified type [T] from the request.
  T? getRequestOption<T>() {
    final option = _requestOptions[T.toString()];
    if (option != null) {
      return option as T;
    }

    return null;
  }
}
