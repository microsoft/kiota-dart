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
