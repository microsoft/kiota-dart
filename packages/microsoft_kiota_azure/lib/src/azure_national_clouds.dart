part of '../microsoft_kiota_azure.dart';

/// Collection of constants representing the national clouds of Azure.
/// These values can be passed to the [TokenCredential] implementations to target different environments
class AzureNationalClouds {
  /// The Azure national cloud for the United States Government.
  static const String usGovernment = 'login.microsoftonline.us';

  /// The Azure national cloud for China operated by 21 Vianet.
  static const String china21ViaNet = 'login.partner.microsoftonline.cn';

  /// The default public cloud for Azure.
  static const String publicCloud = 'login.microsoftonline.com';
}
