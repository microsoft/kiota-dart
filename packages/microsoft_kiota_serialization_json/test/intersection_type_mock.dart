import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

import './microsoft_graph_user.dart';
import './second_test_entity.dart';

class IntersectionTypeMock extends Parsable implements AdditionalDataHolder {
  IntersectionTypeMock();

  static IntersectionTypeMock createFromDiscriminatorValue(
    ParseNode parseNode,
  ) {
    final result = IntersectionTypeMock();
    if (parseNode.getStringValue() != null) {
      result.stringValue = parseNode.getStringValue();
    } else if (parseNode
        .getCollectionOfObjectValues<MicrosoftGraphUser>(
          MicrosoftGraphUser.createFromDiscriminator,
        )
        .isNotEmpty) {
      result.composedType3 =
          parseNode.getCollectionOfObjectValues<MicrosoftGraphUser>(
        MicrosoftGraphUser.createFromDiscriminator,
      );
    } else {
      result
        ..composedType1 = MicrosoftGraphUser()
        ..composedType2 = SecondTestEntity();
    }
    return result;
  }

  MicrosoftGraphUser? composedType1;
  SecondTestEntity? composedType2;
  String? stringValue;
  Iterable<MicrosoftGraphUser>? composedType3;

  @override
  Map<String, Object?> additionalData = {};

  @override
  Map<String, void Function(ParseNode parseNode)> getFieldDeserializers() {
    final deserializers = <String, void Function(ParseNode node)>{};
    if (composedType1 != null) {
      composedType1!
          .getFieldDeserializers()
          .forEach((k, v) => deserializers.putIfAbsent(k, () => v));
    }
    if (composedType2 != null) {
      composedType2!
          .getFieldDeserializers()
          .forEach((k, v) => deserializers.putIfAbsent(k, () => v));
    }
    return deserializers;
  }

  @override
  void serialize(SerializationWriter writer) {
    if (stringValue?.isNotEmpty ?? false) {
      writer.writeStringValue(null, stringValue);
    } else if (composedType3 != null) {
      writer.writeCollectionOfObjectValues(null, composedType3);
    } else {
      writer.writeObjectValue(null, composedType1, [composedType2]);
    }
  }
}
