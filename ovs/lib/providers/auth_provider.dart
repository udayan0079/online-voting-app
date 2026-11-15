import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  OrganizationModel? _currentOrg;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  OrganizationModel? get currentOrg => _currentOrg;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && StorageService.hasToken();
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isVoter => _currentUser?.isVoter ?? false;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Restore session from cache
  Future<bool> restoreSession() async {
    if (StorageService.hasToken()) {
      _currentUser = StorageService.getUser();
      _currentOrg = StorageService.getOrganization();
      notifyListeners();
      return _currentUser != null;
    }
    return false;
  }

  // 1. Admin Registration (New Org + Admin Account in Firebase)
  Future<bool> registerAdmin({
    required String orgName,
    required String orgCode,
    required String adminName,
    required String adminCompanyId,
    required String password,
    String email = '',
    String address = '',
    String description = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await FirebaseService.registerAdmin(
      orgName: orgName,
      orgCode: orgCode,
      adminName: adminName,
      adminCompanyId: adminCompanyId,
      password: password,
      address: address,
      description: description,
      email: email,
    );

    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      _currentOrg = res['organization'];
      await StorageService.saveToken('firebase_session_${_currentUser!.companyId}');
      await StorageService.saveUser(_currentUser!);
      await StorageService.saveOrganization(_currentOrg!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  // 2. Admin Login
  Future<bool> loginAdmin({
    required String orgCode,
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await FirebaseService.loginAdmin(
      orgCode: orgCode,
      identifier: identifier,
      password: password,
    );

    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      _currentOrg = res['organization'];
      await StorageService.saveToken('firebase_session_${_currentUser!.companyId}');
      await StorageService.saveUser(_currentUser!);
      await StorageService.saveOrganization(_currentOrg!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  // 3. Voter Check Whitelist ID
  Future<Map<String, dynamic>> verifyVoterId({
    required String orgCode,
    required String companyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await FirebaseService.verifyVoterId(
      orgCode: orgCode,
      companyId: companyId,
    );

    _isLoading = false;
    notifyListeners();

    if (res['success'] == true) {
      return {
        'success': true,
        'message': res['message'],
        'prefilled': res['prefilled'],
        'organization': res['organization'],
      };
    } else {
      _errorMessage = res['message'];
      return {
        'success': false,
        'message': res['message'],
      };
    }
  }

  // 4. Voter Registration
  Future<bool> registerVoter({
    required String orgCode,
    required String companyId,
    required String name,
    required String password,
    String department = '',
    String email = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await FirebaseService.registerVoter(
      orgCode: orgCode,
      companyId: companyId,
      name: name,
      password: password,
      department: department,
    );

    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      _currentOrg = res['organization'];
      await StorageService.saveToken('firebase_session_${_currentUser!.companyId}');
      await StorageService.saveUser(_currentUser!);
      await StorageService.saveOrganization(_currentOrg!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  // 5. Voter Login
  Future<bool> loginVoter({
    required String orgCode,
    required String companyId,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await FirebaseService.loginVoter(
      orgCode: orgCode,
      companyId: companyId,
      password: password,
    );

    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      _currentOrg = res['organization'];
      await StorageService.saveToken('firebase_session_${_currentUser!.companyId}');
      await StorageService.saveUser(_currentUser!);
      await StorageService.saveOrganization(_currentOrg!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  // 6. Logout
  Future<void> logout() async {
    await StorageService.clearSession();
    _currentUser = null;
    _currentOrg = null;
    _errorMessage = null;
    notifyListeners();
  }
}
