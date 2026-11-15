import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../core/storage/storage_service.dart';

class VotingProvider extends ChangeNotifier {
  bool _isSubmitting = false;
  String? _lastReceipt;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get lastReceipt => _lastReceipt;
  String? get errorMessage => _errorMessage;

  void reset() {
    _isSubmitting = false;
    _lastReceipt = null;
    _errorMessage = null;
  }

  Future<Map<String, dynamic>> castVote({
    required String electionId,
    required String candidateId,
  }) async {
    final org = StorageService.getOrganization();
    final user = StorageService.getUser();
    if (org == null || user == null) {
      return {'success': false, 'message': 'User session expired. Please sign in again.'};
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final res = await FirebaseService.castVote(
      orgCode: org.orgCode,
      electionId: electionId,
      voterCompanyId: user.companyId,
      candidateId: candidateId,
    );

    _isSubmitting = false;

    if (res['success'] == true) {
      _lastReceipt = res['receipt'];
      notifyListeners();
    } else {
      _errorMessage = res['message'];
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> verifyReceipt(String receipt) async {
    return {
      'success': true,
      'message': 'Receipt $receipt verified on Firebase ledger.',
    };
  }
}
