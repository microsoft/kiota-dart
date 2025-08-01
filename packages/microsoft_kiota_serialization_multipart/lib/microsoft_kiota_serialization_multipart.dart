/// This library implements deserialization for multipart responses.
///
/// This library is not meant to be used directly, but rather to be used as a
/// dependency in the generated code.
library microsoft_kiota_serialization_multipart;

import 'dart:convert';

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:uuid/uuid_value.dart';

part 'src/multipart_serialization_writer.dart';
part 'src/multipart_serialization_writer_factory.dart';
