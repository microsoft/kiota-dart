part of '../microsoft_kiota_azure.dart';

/// Represents the device code information as returned by the service.
/// The userCode is the code that the user needs to enter on the verification page.
/// The deviceCode is the code that the service uses to identify the device.
/// The verificationUri is the URL that the user needs to go to and enter the userCode.
/// The expiresIn is the time in seconds that the user has to enter the userCode.
/// The interval is the time in seconds that the client should wait between polling for the token.
/// The message is a message that can be displayed to the user.
class DeviceCodeInfo {
  DeviceCodeInfo(
    this.userCode,
    this.deviceCode,
    this.verificationUri,
    this.expiresIn,
    this.interval,
    this.message,
  );
  DeviceCodeInfo.fromJson(Map<String, dynamic> json)
      : userCode =
            json['user_code'] is String ? json['user_code'] as String : null,
        deviceCode = json['device_code'] is String
            ? json['device_code'] as String
            : null,
        verificationUri = json['verification_uri'] is String
            ? Uri.parse(json['verification_uri'] as String)
            : null,
        expiresIn =
            json['expires_in'] is int ? json['expires_in'] as int : null,
        interval = json['interval'] is int ? json['interval'] as int : null,
        message = json['message'] is String ? json['message'] as String : null;
  final String? userCode;
  final String? deviceCode;
  final Uri? verificationUri;
  final int? expiresIn;
  final int? interval;
  final String? message;
}
