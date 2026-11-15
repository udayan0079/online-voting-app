import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../core/storage/storage_service.dart';
import '../models/election_model.dart';

class ElectionProvider extends ChangeNotifier {
  List<ElectionModel> _elections = [];
  ElectionModel? _selectedElection;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'ALL';
  StreamSubscription? _sub;

  List<ElectionModel> get elections => _elections;
  ElectionModel? get selectedElection => _selectedElection;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  List<ElectionModel> get activeElections =>
      _elections.where((e) => e.isActive).toList();

  List<ElectionModel> get upcomingElections =>
      _elections.where((e) => e.isUpcoming).toList();

  List<ElectionModel> get completedElections =>
      _elections.where((e) => e.isCompleted).toList();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> fetchElections({String? status, String? category}) async {
    final org = StorageService.getOrganization();
    final user = StorageService.getUser();
    if (org == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _sub?.cancel();
    _sub = FirebaseService.streamElections(org.orgCode, user?.companyId ?? '').listen((list) {
      _isLoading = false;
      var filtered = list;

      if (category != null && category.isNotEmpty) {
        filtered = filtered.where((e) => e.category.toLowerCase() == category.toLowerCase()).toList();
      }

      if (status != null && status != 'ALL') {
        filtered = filtered.where((e) => e.status == status).toList();
      }

      _elections = filtered;
      notifyListeners();
    }, onError: (err) {
      _isLoading = false;
      _errorMessage = err.toString();
      notifyListeners();
    });
  }

  Future<ElectionModel?> fetchElectionById(String id) async {
    final org = StorageService.getOrganization();
    final user = StorageService.getUser();
    if (org == null) return null;

    final el = await FirebaseService.getElectionById(org.orgCode, id, user?.companyId ?? '');
    _selectedElection = el;
    notifyListeners();
    return el;
  }

  Future<bool> createElection({
    required String title,
    required String category,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> candidates,
  }) async {
    final org = StorageService.getOrganization();
    if (org == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await FirebaseService.createElection(
      orgCode: org.orgCode,
      title: title,
      category: category,
      description: description,
      startTime: startTime,
      endTime: endTime,
      candidates: candidates,
    );

    _isLoading = false;
    if (success) {
      await fetchElections();
    }
    notifyListeners();
    return success;
  }

  Future<bool> closeElection(String id) async {
    final org = StorageService.getOrganization();
    if (org == null) return false;

    return await FirebaseService.closeElectionEarly(org.orgCode, id);
  }

  Future<bool> deleteElection(String id) async {
    final org = StorageService.getOrganization();
    if (org == null) return false;

    return await FirebaseService.deleteElection(org.orgCode, id);
  }
}
