part of '../microsoft_kiota_http.dart';

class HttpClientRequestAdapter implements RequestAdapter {
  HttpClientRequestAdapter({
    required AuthenticationProvider authProvider,
    ParseNodeFactory? pNodeFactory,
    SerializationWriterFactory? sWriterFactory,
    http.Client? client,
  })  : _authProvider = authProvider,
        _pNodeFactory =
            pNodeFactory ?? ParseNodeFactoryRegistry.defaultInstance,
        _sWriterFactory = sWriterFactory ??
            SerializationWriterFactoryRegistry.defaultInstance,
        _client = client ?? KiotaClientFactory.createClient();

  static const String _claimsKey = 'claims';

  final http.Client _client;
  final AuthenticationProvider _authProvider;

  // ignore: prefer_final_fields
  ParseNodeFactory _pNodeFactory;

  // ignore: prefer_final_fields
  SerializationWriterFactory _sWriterFactory;

  String? _baseUrl;

  @override
  String? get baseUrl => _baseUrl;

  @override
  set baseUrl(String? value) {
    if (value?.endsWith('/') ?? false) {
      _baseUrl = value?.substring(0, value.length - 1);
    } else {
      _baseUrl = value;
    }
  }

  http.BaseRequest _getMessageFromInfo(
    RequestInformation requestInfo,
  ) {
    final request = http.Request(
      requestInfo.httpMethod!.value,
      requestInfo.uri,
    );

    if (requestInfo.headers.isNotEmpty) {
      final flattenedHeaders = requestInfo.headers.map((name, values) {
        // according to https://stackoverflow.com/a/3097052/5107884 it is
        // possible to concatenate multiple header values for the same name with
        // a comma
        return MapEntry(name, values.join(', '));
      });

      request.headers.addAll(flattenedHeaders);
    }

    if (requestInfo.content case final Uint8List content) {
      request.bodyBytes = content;
    }

    return request;
  }

  Future<http.StreamedResponse> _getResponse(
    RequestInformation requestInfo, [
    String? claims,
  ]) async {
    _setBaseUrl(requestInfo);

    Map<String, Object>? additionalAuthContext;
    if (claims != null) {
      additionalAuthContext = {_claimsKey: claims};
    }

    await _authProvider.authenticateRequest(requestInfo, additionalAuthContext);

    final message = _getMessageFromInfo(requestInfo);

    return _client.send(message);
  }

  void _setBaseUrl(RequestInformation requestInfo) {
    requestInfo.pathParameters['baseurl'] = baseUrl;
  }

  ResponseHandler? _getResponseHandler(RequestInformation requestInfo) {
    final option = requestInfo.getRequestOption<ResponseHandlerOption>();

    return option?.responseHandler;
  }

  Future<void> _throwIfFailedResponse(
    http.StreamedResponse response,
    ErrorMappings? errorMapping,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 400) {
      return;
    }

    final statusCodeInt = response.statusCode;
    final statusCodeString = response.statusCode.toString();
    final headers = response.headersSplitValues;

    final ParsableFactory? errorFactory;
    if (errorMapping == null) {
      errorFactory = null;
    } else if (errorMapping.containsKey(statusCodeString)) {
      errorFactory = errorMapping[statusCodeString];
    } else if (statusCodeInt >= 400 &&
        statusCodeInt < 500 &&
        errorMapping.containsKey('4XX')) {
      errorFactory = errorMapping['4XX'];
    } else if (statusCodeInt >= 500 &&
        statusCodeInt < 600 &&
        errorMapping.containsKey('5XX')) {
      errorFactory = errorMapping['5XX'];
    } else {
      errorFactory = errorMapping['XXX'];
    }

    if (errorFactory == null) {
      throw ApiException(
        statusCode: statusCodeInt,
        message:
            'The server returned an unexpected status code and no error factory is registered for this code: $statusCodeString',
        responseHeaders: headers,
      );
    }

    final rootNode = await _getRootParseNode(response);
    final result = rootNode?.getObjectValue(errorFactory);

    if (result case Exception exception) {
      if (exception case final ApiException apiException) {
        exception = apiException.copyWith(
          statusCode: statusCodeInt,
          responseHeaders: headers,
        );
      }

      throw exception;
    }

    throw ApiException(
      statusCode: statusCodeInt,
      message:
          'The server returned an unexpected status code and the error registered for this code failed to deserialize: $statusCodeString',
      responseHeaders: headers,
    );
  }

  bool _shouldReturnNull(http.StreamedResponse response) {
    return response.statusCode == 204 || response.contentLength == 0;
  }

  Future<ParseNode?> _getRootParseNode(http.StreamedResponse response) async {
    final responseContentType = response.headers['content-type'];
    if (responseContentType == null || responseContentType.isEmpty) {
      return null;
    }

    final content = await response.stream.toBytes();

    return _pNodeFactory.getRootParseNode(responseContentType, content);
  }

  @override
  Future<T?> convertToNativeRequest<T>(RequestInformation requestInfo) async {
    await _authProvider.authenticateRequest(requestInfo);

    final request = _getMessageFromInfo(requestInfo);
    if (request is T) {
      return request as T;
    }

    throw ArgumentError(
      'The request could not be converted to the desired type $T',
    );
  }

  Future<ParseNode?> _sendRequestAndHandleResponse(
    RequestInformation requestInfo,
    ErrorMappings? errorMapping,
  ) async {
    final response = await _getResponse(requestInfo);

    final handler = _getResponseHandler(requestInfo);
    if (handler != null) {
      return handler.handleResponse(response, errorMapping);
    }

    await _throwIfFailedResponse(response, errorMapping);

    if (_shouldReturnNull(response)) {
      return null;
    }

    return _getRootParseNode(response);
  }

  @override
  Future<ModelType?> send<ModelType extends Parsable>(
    RequestInformation requestInfo,
    ParsableFactory<ModelType> factory, [
    ErrorMappings? errorMapping,
  ]) async {
    final rootNode =
        await _sendRequestAndHandleResponse(requestInfo, errorMapping);

    return rootNode?.getObjectValue<ModelType>(factory);
  }

  @override
  Future<Iterable<ModelType>?> sendCollection<ModelType extends Parsable>(
    RequestInformation requestInfo,
    ParsableFactory<ModelType> factory, [
    ErrorMappings? errorMapping,
  ]) async {
    final rootNode =
        await _sendRequestAndHandleResponse(requestInfo, errorMapping);

    return rootNode?.getCollectionOfObjectValues<ModelType>(factory);
  }

  @override
  Future<void> sendNoContent(
    RequestInformation requestInfo, [
    ErrorMappings? errorMapping,
  ]) async {
    final response = await _getResponse(requestInfo);

    final handler = _getResponseHandler(requestInfo);
    if (handler != null) {
      await handler.handleResponse(response, errorMapping);

      return;
    }

    await _throwIfFailedResponse(response, errorMapping);
  }

  @pragma('vm:prefer-inline')
  bool _isExactly<T, U>() => T == U;

  @pragma('vm:prefer-inline')
  bool _isSubtype<T, U>() => <T>[] is List<U>;

  @override
  Future<ModelType?> sendPrimitive<ModelType>(
    RequestInformation requestInfo, [
    ErrorMappings? errorMapping,
  ]) async {
    final rootNode =
        await _sendRequestAndHandleResponse(requestInfo, errorMapping);

    if (rootNode == null) {
      return null;
    }

    if (_isExactly<ModelType, bool>() || _isExactly<ModelType, bool?>()) {
      return rootNode.getBoolValue() as ModelType;
    } else if (_isExactly<ModelType, int>() || _isExactly<ModelType, int?>()) {
      return rootNode.getIntValue() as ModelType;
    } else if (_isExactly<ModelType, double>() || _isExactly<ModelType, double?>()) {
      return rootNode.getDoubleValue() as ModelType;
    } else if (_isExactly<ModelType, String>() || _isExactly<ModelType, String?>()) {
      return rootNode.getStringValue() as ModelType;
    } else if (_isExactly<ModelType, DateTime>() || _isExactly<ModelType, DateTime?>()) {
      return rootNode.getDateTimeValue() as ModelType;
    } else if (_isExactly<ModelType, DateOnly>() || _isExactly<ModelType, DateOnly?>() || _isSubtype<ModelType, DateOnly?>()) {
      return rootNode.getDateOnlyValue() as ModelType;
    } else if (_isExactly<ModelType, TimeOnly>() || _isExactly<ModelType, TimeOnly?>() || _isSubtype<ModelType, TimeOnly?>()) {
      return rootNode.getTimeOnlyValue() as ModelType;
    } else if (_isExactly<ModelType, Duration>() || _isExactly<ModelType, Duration?>()) {
      return rootNode.getDurationValue() as ModelType;
    } else if (_isExactly<ModelType, UuidValue>() || _isExactly<ModelType, UuidValue?>()) {
      return rootNode.getGuidValue() as ModelType;
    } else {
      throw ArgumentError(
        'The type $ModelType is not supported for primitive deserialization',
      );
    }
  }

  @override
  Future<Iterable<ModelType>?> sendPrimitiveCollection<ModelType>(
    RequestInformation requestInfo, [
    ErrorMappings? errorMapping,
  ]) async {
    final rootNode =
        await _sendRequestAndHandleResponse(requestInfo, errorMapping);

    return rootNode?.getCollectionOfPrimitiveValues<ModelType>();
  }

  @override
  SerializationWriterFactory get serializationWriterFactory => _sWriterFactory;

  @override
  void enableBackingStore(BackingStoreFactory backingStoreFactory) {
    _pNodeFactory =
        ApiClientBuilder.enableBackingStoreForParseNodeFactory(_pNodeFactory);
    _sWriterFactory =
        ApiClientBuilder.enableBackingStoreForSerializationWriterFactory(
      _sWriterFactory,
    );
    BackingStoreFactorySingleton.instance = backingStoreFactory;
  }
}
