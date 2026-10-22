part of '../../microsoft_kiota_abstractions.dart';

HashSet<String> _createCaseInsensitiveHashSet() {
  return HashSet(
    equals: (a, b) => a.toUpperCase() == b.toUpperCase(),
    hashCode: (o) => o.toUpperCase().hashCode,
  );
}

/// Validator for handling allowed hosts for authentication.
class AllowedHostsValidator {
  /// Initializes a new instance of the [AllowedHostsValidator] class.
  AllowedHostsValidator([Iterable<String>? validHosts]) {
    validHosts ??= <String>[];
    _validateHosts(validHosts);
    _allowedHosts = _createCaseInsensitiveHashSet()
      ..addAll(validHosts.map((h) => h.trim()).where((h) => h.isNotEmpty));
  }

  Set<String> _allowedHosts = {};

  /// Gets the allowed hosts.
  Iterable<String> get allowedHosts => _allowedHosts;

  /// Sets the allowed hosts.
  set allowedHosts(Iterable<String> value) {
    _validateHosts(value);
    _allowedHosts = _createCaseInsensitiveHashSet()
      ..addAll(value.map((h) => h.trim()).where((h) => h.isNotEmpty));
  }

  /// Validates that the given [uri] is valid.
  bool isUrlHostValid(Uri uri) {
    if (!uri.hasScheme || uri.host.isEmpty) {
      return false;
    }
    if (_allowedHosts.isEmpty || _allowedHosts.contains(uri.host)) {
      return true;
    }
    final host = uri.host.toLowerCase();
    return _allowedHosts.any(
      (allowedHost) =>
          allowedHost.startsWith('.') &&
          host.endsWith(allowedHost.toLowerCase()),
    );
  }

  static void _validateHosts(Iterable<String> hostsToValidate) {
    for (final host in hostsToValidate) {
      final normalized = host.trim().toLowerCase();
      if (normalized.startsWith('http://') ||
          normalized.startsWith('https://')) {
        throw ArgumentError.value(
          host,
          null,
          'Host should not contain http or https prefix',
        );
      }
    }
  }
}
