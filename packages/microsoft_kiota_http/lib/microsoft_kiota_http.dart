/// This library implements a request adapter for generated
/// [Kiota](https://github.com/microsoft/kiota) clients.
library microsoft_kiota_http;

import 'package:http/http.dart' as http;
import 'package:http/retry.dart' as retry;
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:uuid/uuid.dart';

part 'src/http_client_request_adapter.dart';
part 'src/kiota_client_factory.dart';
part 'src/middleware/user_agent_client.dart';
