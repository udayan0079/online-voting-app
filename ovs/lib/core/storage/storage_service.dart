import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/organization_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token
  static Future<void> saveToken(String token) async {
    await prefs.setString(AppConstants.keyToken, token);
  }

  static String? getToken() {
    return prefs.getString(AppConstants.keyToken);
  }

  static bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // User
  static Future<void> saveUser(UserModel user) async {
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final userJson = prefs.getString(AppConstants.keyUserData);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  // Organization
  static Future<void> saveOrganization(OrganizationModel org) async {
    await prefs.setString(AppConstants.keyOrgData, jsonEncode(org.toJson()));
    await prefs.setString(AppConstants.keyLastOrgCode, org.orgCode);
  }

  static OrganizationModel? getOrganization() {
    final orgJson = prefs.getString(AppConstants.keyOrgData);
    if (orgJson == null) return null;
    try {
      return OrganizationModel.fromJson(jsonDecode(orgJson));
    } catch (_) {
      return null;
    }
  }

  static String? getLastOrgCode() {
    return prefs.getString(AppConstants.keyLastOrgCode);
  }

  // Custom Base URL
  static Future<void> saveBaseUrl(String url) async {
    await prefs.setString(AppConstants.keyCustomBaseUrl, url);
  }

  static String getBaseUrl() {
    final custom = prefs.getString(AppConstants.keyCustomBaseUrl);
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return AppConstants.defaultBaseUrl;
  }

  // Guide Language
  static Future<void> saveGuideLanguage(String langCode) async {
    await prefs.setString('pref_guide_language', langCode);
  }

  static String getGuideLanguage() {
    return prefs.getString('pref_guide_language') ?? 'en';
  }

  // Clear Session
  static Future<void> clearSession() async {
    final savedOrgCode = getLastOrgCode();
    final customUrl = prefs.getString(AppConstants.keyCustomBaseUrl);
    final guideLang = getGuideLanguage();
    await prefs.clear();
    if (savedOrgCode != null) {
      await prefs.setString(AppConstants.keyLastOrgCode, savedOrgCode);
    }
    if (customUrl != null) {
      await prefs.setString(AppConstants.keyCustomBaseUrl, customUrl);
    }
    await prefs.setString('pref_guide_language', guideLang);
  }
}
