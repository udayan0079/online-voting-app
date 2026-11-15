import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConstants {
  static const String appName = 'SmartVote Corporate';
  static const String appTagline = 'Secure Multi-Tenant Enterprise Voting System';

  // Dynamic Base URL detection for Android Emulator vs Windows/Web/Device
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        // Android emulator maps host machine to 10.0.2.2
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:5000/api';
  }

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyOrgData = 'org_data';
  static const String keyLastOrgCode = 'last_org_code';
  static const String keyCustomBaseUrl = 'custom_base_url';

  // Common Election Categories / Sub-types
  static const List<String> popularCategories = [
    'HR Representative',
    'Class Representative (CR)',
    'President',
    'Prime Minister',
    'Member of Parliament (MP)',
    'Department Head',
    'General Secretary',
    'Employee Union Leader',
    'Board Director',
  ];
}
