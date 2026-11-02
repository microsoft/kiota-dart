// ignore_for_file: avoid_redundant_argument_values

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:test/test.dart';

void main() {
  group('CaseInsensitiveMap', () {
    test('putIfAbsent', () {
      final headers = HttpHeaders()
        ..putIfAbsent('key', () => {'value'})
        ..map((name, values) {
          return MapEntry(name, values.join(', '));
        });
      expect(headers['key'], {'value'});
    });

    test(
      'update with ifAbsent sets originalKey and works with entries and keys',
      () {
        final headers = HttpHeaders()
          ..update('My-Header', (v) => v, ifAbsent: () => {'value'})
          ..map((name, values) {
            return MapEntry(name, values.join(', '));
          });
        expect(headers['my-header'], {'value'});
        expect(headers.keys.toList(), ['My-Header']);
        expect(headers.entries.first.key, 'My-Header');
      },
    );
  });
}
