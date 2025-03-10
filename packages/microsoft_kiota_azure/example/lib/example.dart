// ignore_for_file: unused_local_variable
import 'package:microsoft_kiota_azure/microsoft_kiota_azure.dart';
import 'package:microsoft_kiota_bundle/microsoft_kiota_bundle.dart';

Future<void> main() async {
  // choose your authentication flow:
  final credential = await deviceCodeFlow();

  final authProvider = AzureAuthenticationProvider.withCredential(
    credential,
    scopes: ['User.Read'],
  );
  final adapter = DefaultRequestAdapter(authProvider: authProvider);

  // ... pass adapter to the generated API client
}

Future<DeviceCodeCredential> deviceCodeFlow() async {
  return DeviceCodeCredential('clientId', (deviceCodeInfo) {
    print(deviceCodeInfo.message);
    print('Please go to ${deviceCodeInfo.verificationUri} and enter the code');
  });
}
