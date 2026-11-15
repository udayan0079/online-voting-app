import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../core/storage/storage_service.dart';
import '../models/whitelist_model.dart';

class WhitelistProvider extends ChangeNotifier {
  List<WhitelistModel> _whitelist = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalAuthorized = 0;
  int _registeredVoters = 0;
  int _pendingRegistration = 0;
  StreamSubscription? _sub;

  List<WhitelistModel> get whitelist => _whitelist;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalAuthorized => _totalAuthorized;
  int get registeredVoters => _registeredVoters;
  int get pendingRegistration => _pendingRegistration;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> fetchWhitelist({String? search, String? status}) async {
    final org = StorageService.getOrganization();
    if (org == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _sub?.cancel();
    _sub = FirebaseService.streamWhitelist(org.orgCode).listen((list) {
      _isLoading = false;
      var filtered = list;

      if (search != null && search.trim().isNotEmpty) {
        final query = search.trim().toLowerCase();
        filtered = filtered.where((w) =>
            w.companyId.toLowerCase().contains(query) ||
            w.name.toLowerCase().contains(query) ||
            w.department.toLowerCase().contains(query)).toList();
      }

      if (status == 'registered') {
        filtered = filtered.where((w) => w.isRegistered).toList();
      } else if (status == 'pending') {
        filtered = filtered.where((w) => !w.isRegistered).toList();
      }

      _whitelist = filtered;
      _totalAuthorized = list.length;
      _registeredVoters = list.where((w) => w.isRegistered).length;
      _pendingRegistration = _totalAuthorized - _registeredVoters;
      notifyListeners();
    }, onError: (err) {
      _isLoading = false;
      _errorMessage = err.toString();
      notifyListeners();
    });
  }

  Future<bool> addSingleId({
    required String companyId,
    String name = '',
    String department = '',
  }) async {
    final org = StorageService.getOrganization();
    if (org == null) return false;

    _isLoading = true;
    notifyListeners();

    final success = await FirebaseService.addSingleWhitelistId(
      orgCode: org.orgCode,
      companyId: companyId,
      name: name,
      department: department,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> addBulkIds(String rawIds) async {
    final org = StorageService.getOrganization();
    if (org == null) return false;

    _isLoading = true;
    notifyListeners();

    final success = await FirebaseService.addBulkWhitelistIds(
      orgCode: org.orgCode,
      rawIds: rawIds,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteId(String id) async {
    final org = StorageService.getOrganization();
    if (org == null) return false;

    final success = await FirebaseService.deleteWhitelistId(
      orgCode: org.orgCode,
      id: id,
    );
    return success;
  }
}
