import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_form/microsoft_kiota_serialization_form.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'form_parse_node_test.mocks.dart';

HttpMethod? _httpMethodEnumFactory(String value) => HttpMethod.values
    .cast<HttpMethod?>()
    .firstWhere((e) => e!.name == value, orElse: () => null);

@GenerateMocks([Parsable])
void main() {
  group('FormParseNode', () {
    test('leaves quotes if unbalanced', () {
      final preQuote = FormParseNode('"value');
      final postQuote = FormParseNode('value"');

      expect(preQuote.getStringValue(), equals('"value'));
      expect(postQuote.getStringValue(), equals('value"'));
    });

    test('getStringValue', () {
      final node = FormParseNode('value');

      expect(node.getStringValue(), equals('value'));
    });

    test('getBoolValue', () {
      final node = FormParseNode('true');

      expect(node.getBoolValue(), equals(true));
    });

    test('getByteArrayValue', () {
      final node = FormParseNode('dGVzdA==');

      expect(node.getByteArrayValue(), equals([116, 101, 115, 116]));
    });

    test('getDateOnlyValue', () {
      final node = FormParseNode('2021-01-01');

      expect(node.getDateOnlyValue(), equals(DateOnly.fromComponents(2021)));
    });

    test('getDateTimeValue', () {
      final node = FormParseNode('2021-01-01T00:00:00Z');

      expect(node.getDateTimeValue(), equals(DateTime.utc(2021)));
    });

    test('getDoubleValue', () {
      final node = FormParseNode('1.23');

      expect(node.getDoubleValue(), equals(1.23));
    });

    test('getDurationValue', () {
      final node = FormParseNode('P3DT4H5M6S');

      expect(
        node.getDurationValue(),
        equals(const Duration(days: 3, hours: 4, minutes: 5, seconds: 6)),
      );
    });

    test('getGuidValue nil', () {
      final node = FormParseNode('00000000-0000-0000-0000-000000000000');

      expect(node.getGuidValue(), equals(Namespace.nil.uuidValue));
    });

    test('getGuidValue', () {
      final node = FormParseNode('1f8a1626-369d-41df-bcc4-af5c5adbbd0a');

      expect(
        node.getGuidValue(),
        // ignore: experimental_member_use
        equals(UuidValue.fromString('1f8a1626-369d-41df-bcc4-af5c5adbbd0a')),
      );
    });

    test('getIntValue', () {
      final node = FormParseNode('123');

      expect(node.getIntValue(), equals(123));
    });

    test('getTimeOnlyValue', () {
      final node = FormParseNode('12:34:56');

      expect(
        node.getTimeOnlyValue(),
        equals(TimeOnly.fromComponents(12, 34, 56)),
      );
    });

    test('getEnumValue', () {
      final node = FormParseNode('get');

      expect(
        node.getEnumValue<HttpMethod>(_httpMethodEnumFactory),
        equals(HttpMethod.get),
      );
    });

    test('getChildNode', () {
      final node = FormParseNode('value');

      expect(node.getChildNode('identifier'), isNull);
    });

    test('getCollectionOfObjectValues', () {
      final node = FormParseNode('value');

      expect(
        () => node.getCollectionOfObjectValues<MultipartBody>(
          (_) => MultipartBody(),
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            equals('Collections are not supported with uri form encoding'),
          ),
        ),
      );
    });

    test('getCollectionOfPrimitiveValues<bool>', () {
      final node = FormParseNode('false,true');

      expect(
        node.getCollectionOfPrimitiveValues<bool>(),
        equals([false, true]),
      );
    });

    test('getCollectionOfPrimitiveValues<int>', () {
      final node = FormParseNode('123,null,456');

      expect(node.getCollectionOfPrimitiveValues<int>(), equals([123, 456]));
    });

    test('getCollectionOfPrimitiveValues<double>', () {
      final node = FormParseNode('1.1,2.2,3.3');

      expect(
        node.getCollectionOfPrimitiveValues<double>(),
        equals([1.1, 2.2, 3.3]),
      );
    });

    test('getCollectionOfPrimitiveValues<String> skips null entries', () {
      final node = FormParseNode('hello,null,world');

      expect(
        node.getCollectionOfPrimitiveValues<String>(),
        equals(['hello', 'world']),
      );
    });

    test('getCollectionOfPrimitiveValues<DateTime>', () {
      final node = FormParseNode(
        '2021-01-01T00:00:00Z,2022-06-15T12:30:00Z',
      );

      expect(
        node.getCollectionOfPrimitiveValues<DateTime>(),
        equals([DateTime.utc(2021), DateTime.utc(2022, 6, 15, 12, 30)]),
      );
    });

    test('getCollectionOfPrimitiveValues<DateOnly>', () {
      final node = FormParseNode('2021-01-01,2022-06-15');

      expect(
        node.getCollectionOfPrimitiveValues<DateOnly>(),
        equals([
          DateOnly.fromComponents(2021),
          DateOnly.fromComponents(2022, 6, 15),
        ]),
      );
    });

    test('getCollectionOfPrimitiveValues<TimeOnly>', () {
      final node = FormParseNode('08:00:00,17:30:00');

      expect(
        node.getCollectionOfPrimitiveValues<TimeOnly>(),
        equals([TimeOnly.fromComponents(8, 0), TimeOnly.fromComponents(17, 30)]),
      );
    });

    test('getCollectionOfPrimitiveValues<Duration>', () {
      final node = FormParseNode('PT1H,P3DT4H5M6S');

      expect(
        node.getCollectionOfPrimitiveValues<Duration>(),
        equals([
          const Duration(hours: 1),
          const Duration(days: 3, hours: 4, minutes: 5, seconds: 6),
        ]),
      );
    });

    test('getCollectionOfPrimitiveValues<UuidValue>', () {
      final node = FormParseNode(
        '1f8a1626-369d-41df-bcc4-af5c5adbbd0a,'
        '00000000-0000-0000-0000-000000000000',
      );

      expect(
        // ignore: experimental_member_use
        node.getCollectionOfPrimitiveValues<UuidValue>(),
        equals([
          // ignore: experimental_member_use
          UuidValue.fromString('1f8a1626-369d-41df-bcc4-af5c5adbbd0a'),
          Namespace.nil.uuidValue,
        ]),
      );
    });

    test('getCollectionOfEnumValues', () {
      final node = FormParseNode('get,post');

      final values = node.getCollectionOfEnumValues<HttpMethod>(
        _httpMethodEnumFactory,
      );

      expect(values, equals([HttpMethod.get, HttpMethod.post]));
    });

    test('getCollectionOfEnumValues is case sensitive', () {
      final node = FormParseNode('GET,Post');

      final values = node.getCollectionOfEnumValues<HttpMethod>(
        _httpMethodEnumFactory,
      );

      expect(values, equals([]));
    });

    test('getObjectValue', () {
      final node = FormParseNode('filename=file.txt');

      final parsable = MockParsable();

      when(parsable.getFieldDeserializers()).thenReturn({
        'filename': (node) {
          final value = node.getStringValue();

          expect(value, equals('file.txt'));
        },
      });

      final value = node.getObjectValue<MockParsable>((_) => parsable);

      expect(value, isNotNull);
    });

    test('FormParseNode parses fields', () {
      final node = FormParseNode(
        'filename=file.txt&size=123&type=null&temp=true',
      );

      final filename = node.getChildNode('filename');
      final size = node.getChildNode('size');
      final type = node.getChildNode('type');
      final temp = node.getChildNode('temp');

      expect(filename, isNotNull);
      expect(filename!.getStringValue(), 'file.txt');

      expect(size, isNotNull);
      expect(size!.getIntValue(), 123);

      expect(type, isNotNull);
      expect(type!.getStringValue(), null);

      expect(temp, isNotNull);
      expect(temp!.getBoolValue(), true);
    });
  });
}
