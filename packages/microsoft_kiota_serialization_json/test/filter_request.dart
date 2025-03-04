import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

class FilterRequest extends Parsable {
  FilterRequest({
    this.fieldName,
    this.operator,
    this.value,
  });

  String? fieldName;
  String? operator;
  UntypedNode? value;

  @override
  void serialize(SerializationWriter writer) {
    writer
      ..writeStringValue('fieldName', fieldName)
      ..writeStringValue('operator', operator)
      ..writeObjectValue<UntypedNode>('value', value);
  }

  @override
  Map<String, void Function(ParseNode)> getFieldDeserializers() {
    return <String, void Function(ParseNode node)>{
      'fieldName': (node) => fieldName = node.getStringValue(),
      'operator': (node) => operator = node.getStringValue(),
      'value': (node) => value = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue),
    };
  }

  @override
  String toString() {
    return '''
      fieldName: $fieldName
      operator: $operator
      value: $value
    ''';
  }
}
