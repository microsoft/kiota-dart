part of '../microsoft_kiota_azure.dart';

/// Represents the device code information.
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
      : userCode = json['user_code'] as String,
        deviceCode = json['device_code'] as String,
        verificationUri = Uri.parse(json['verification_uri'] as String),
        expiresIn = json['expires_in'] as int,
        interval = json['interval'] as int,
        message = json['message'] as String;
  final String userCode;
  final String deviceCode;
  final Uri verificationUri;
  final int expiresIn;
  final int interval;
  final String message;
}
