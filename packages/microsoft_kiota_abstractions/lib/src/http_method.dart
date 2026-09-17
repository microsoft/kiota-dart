part of '../microsoft_kiota_abstractions.dart';

/// Represents the HTTP method used by a request.
enum HttpMethod {
  /// The GET method requests a representation of the specified resource. Requests using GET should only retrieve data.
  get('GET'),

  /// The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
  post('POST'),

  /// The PATCH method is used to apply partial modifications to a resource.
  patch('PATCH'),

  /// The DELETE method deletes the specified resource.
  delete('DELETE'),

  /// The OPTIONS method is used to describe the communication options for the target resource.
  options('OPTIONS'),

  /// The PUT method replaces all current representations of the target resource with the request payload.
  put('PUT'),

  /// The HEAD method asks for a response identical to that of a GET request, but without the response body.
  head('HEAD'),

  /// The CONNECT method establishes a tunnel to the server identified by the target resource.
  connect('CONNECT'),

  /// The TRACE method performs a message loop-back test along the path to the target resource.
  trace('TRACE'),

  /// The QUERY method performs a query to the target resource, carrying the query parameters in the request body (RFC 10008).
  query('QUERY');

  const HttpMethod(this.value);

  /// The value or name of the method (for example "GET" or "POST").
  final String value;
}
