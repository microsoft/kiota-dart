/// This library implements an OAuth authentication provider for the
/// [`microsoft_kiota_abstractions`](https://pub.dev/packages/microsoft_kiota_abstractions) package.
library microsoft_kiota_oauth;

import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

part 'src/oauth_access_token_provider.dart';
part 'src/oauth_authentication_provider.dart';
