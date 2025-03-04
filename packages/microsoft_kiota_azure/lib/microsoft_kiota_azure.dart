/// This library implements an Azure authentication provider for the
/// [`microsoft_kiota_abstractions`](https://pub.dev/packages/microsoft_kiota_abstractions) package.
library microsoft_kiota_azure;

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:std_uritemplate/std_uritemplate.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart' as retry;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'dart:convert';
import 'dart:collection';

part 'src/azure_access_token_provider.dart';
part 'src/azure_authentication_provider.dart';
part 'src/token_credential.dart';
part 'src/token_request_context.dart';
part 'src/access_token.dart';
part 'src/device_code_credential.dart';
part 'src/device_code_info.dart';
part 'src/device_code_token_error.dart';
part 'src/device_code_token_response.dart';
part 'src/azure_national_clouds.dart';
//TODO add the other parts of the model
