part of '../microsoft_kiota_azure.dart';

/// Represents the device code information as returned by the service.
/// The [userCode] is the code that the user needs to enter on the verification page.
/// The [deviceCode] is the code that the service uses to identify the device.
/// The [verificationUri] is the URL that the user needs to go to and enter the userCode.
/// The [expiresIn] is the time in seconds that the user has to enter the userCode.
/// The [interval] is the time in seconds that the client should wait between polling for the token.
/// The [message] is a message that can be displayed to the user.
class DeviceCodeInfo {
  /// Creates a new instance of [DeviceCodeInfo].
  DeviceCodeInfo({
    this.userCode,
    this.deviceCode,
    this.verificationUri,
    this.expiresIn,
    this.interval,
    this.message,
  });

  /// Creates a new instance of [DeviceCodeInfo] from a JSON object.
  factory DeviceCodeInfo.fromJson(Map<String, dynamic> json) {
    return DeviceCodeInfo(
      userCode: json['user_code'] as String?,
      deviceCode: json['device_code'] as String?,
      verificationUri: json['verification_uri'] is String
          ? Uri.parse(json['verification_uri'] as String)
          : null,
      expiresIn: json['expires_in'] as int?,
      interval: json['interval'] as int?,
      message: json['message'] as String?,
    );
  }
  final String? userCode;
  final String? deviceCode;
  final Uri? verificationUri;
  final int? expiresIn;
  final int? interval;
  final String? message;
}
