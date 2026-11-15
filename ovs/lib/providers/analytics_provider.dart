import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../core/storage/storage_service.dart';
import '../models/dashboard_stats_model.dart';

class AnalyticsProvider extends ChangeNotifier {
  DashboardStatsModel _stats = DashboardStatsModel();
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStatsModel get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardStats() async {
    final org = StorageService.getOrganization();
    if (org == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await FirebaseService.getDashboardStats(org.orgCode);
      _stats = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
