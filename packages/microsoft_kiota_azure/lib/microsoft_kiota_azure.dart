/// This library implements an Azure authentication provider for the
/// [`microsoft_kiota_abstractions`](https://pub.dev/packages/microsoft_kiota_abstractions) package.
library microsoft_kiota_azure;

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

part 'src/azure_access_token_provider.dart';
part 'src/azure_authentication_provider.dart';
//TODO add the other parts of the model
