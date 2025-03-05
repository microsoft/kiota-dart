import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

import 'intersection_type_mock.dart';

class NestedIntersectionType implements Parsable {
  IntersectionTypeMock? nested;

  @override
  Map<String, void Function(ParseNode p1)> getFieldDeserializers() {
    return {
      'nested': (p) => nested = p.getObjectValue(
        IntersectionTypeMock.createFromDiscriminatorValue,
      ),
    };
  }

  @override
  void serialize(SerializationWriter writer) {
    writer.writeObjectValue('nested', nested);
  }
}
