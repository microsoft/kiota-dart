import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:test/test.dart';

void main() {
  group('AllowedHostsValidator', () {
    test('Throws for hosts with scheme', () {
      expect(
        () => AllowedHostsValidator(['http://example.com']),
        throwsArgumentError,
      );
      expect(
        () => AllowedHostsValidator(['https://example.com']),
        throwsArgumentError,
      );
      expect(
        () => AllowedHostsValidator(['  http://example.com  ']),
        throwsArgumentError,
      );
      expect(
        () => AllowedHostsValidator(['  https://example.com  ']),
        throwsArgumentError,
      );
    });

    test('Is case insensitive', () {
      final validator = AllowedHostsValidator(['example.com']);

      expect(validator.isUrlHostValid(Uri.parse('http://example.com')), isTrue);
      expect(validator.isUrlHostValid(Uri.parse('http://EXAMPLE.com')), isTrue);
    });

    test('Trims host entries', () {
      final validator = AllowedHostsValidator(['  example.com  ']);

      expect(
        validator.isUrlHostValid(Uri.parse('https://example.com/path')),
        isTrue,
      );
    });

    test('Validates subdomain separately', () {
      final validator = AllowedHostsValidator(['example.com']);

      expect(
        validator.isUrlHostValid(Uri.parse('https://sub.example.com/path')),
        isFalse,
      );
    });

    test('Returns true for subdomain matching allowed suffix', () {
      final validator = AllowedHostsValidator(['.fabric.microsoft.com']);

      expect(
        validator.isUrlHostValid(
          Uri.parse('https://abc.123.graphql.fabric.microsoft.com/path'),
        ),
        isTrue,
      );
    });

    test('Returns false for bare domain when allowed as suffix', () {
      final validator = AllowedHostsValidator(['.fabric.microsoft.com']);

      expect(
        validator.isUrlHostValid(
          Uri.parse('https://fabric.microsoft.com/path'),
        ),
        isFalse,
      );
    });

    test('Suffix host matching is case insensitive', () {
      final validator = AllowedHostsValidator(['.Fabric.Microsoft.COM']);

      expect(
        validator.isUrlHostValid(
          Uri.parse('https://ABC.z2c.graphql.fabric.microsoft.com/path'),
        ),
        isTrue,
      );
    });

    test('Only keeps a unique list of hosts', () {
      final validator = AllowedHostsValidator([
        'example.com',
        'example.com',
        'EXAMPLE.COM',
      ]);

      expect(validator.allowedHosts, equals(['example.com']));
    });

    test('Allows multiple valid hosts', () {
      final validator = AllowedHostsValidator([
        'example.com',
        'api.example.com',
        '.fabric.microsoft.com',
      ]);

      expect(
        validator.isUrlHostValid(Uri.parse('https://example.com/path')),
        isTrue,
      );
      expect(
        validator.isUrlHostValid(Uri.parse('https://api.example.com/path')),
        isTrue,
      );
      expect(
        validator.isUrlHostValid(Uri.parse('https://other.com/path')),
        isFalse,
      );
      expect(
        validator.isUrlHostValid(
          Uri.parse('https://abc.123.graphql.fabric.microsoft.com/path'),
        ),
        isTrue,
      );
    });

    test('Allows suffix based hosts after update', () {
      final validator = AllowedHostsValidator(['example.com'])
        ..allowedHosts = ['.fabric.microsoft.com'];

      expect(
        validator.isUrlHostValid(
          Uri.parse('https://abc.123.graphql.fabric.microsoft.com/path'),
        ),
        isTrue,
      );
    });

    test('Validates uri structure when allowedHosts empty', () {
      final validator = AllowedHostsValidator();

      expect(validator.isUrlHostValid(Uri.parse('/path/only')), isFalse);
      expect(
        validator.isUrlHostValid(Uri.parse('https://example.com/path')),
        isTrue,
      );
    });
  });
}
