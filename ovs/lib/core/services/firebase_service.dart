import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../../models/candidate_model.dart';
import '../../models/election_model.dart';
import '../../models/organization_model.dart';
import '../../models/user_model.dart';
import '../../models/whitelist_model.dart';
import '../../models/dashboard_stats_model.dart';
import 'blockchain_service.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper to hash passwords
  static String hashPassword(String password) {
    final bytes = utf8.encode('smartvote_salt_2026_$password');
    return sha256.convert(bytes).toString();
  }

  // Helper to generate cryptographic receipt
  static String generateReceipt(String orgCode, String electionId, String voterId, String candidateId) {
    final raw = '$orgCode-$electionId-$voterId-$candidateId-${DateTime.now().millisecondsSinceEpoch}';
    final hash = sha256.convert(utf8.encode(raw)).toString().substring(0, 16).toUpperCase();
    return 'VOTE-$hash';
  }

  // -------------------------------------------------------------
  // AUTHENTICATION & MULTI-TENANT ONBOARDING
  // -------------------------------------------------------------

  // 1. Register Admin & Organization
  static Future<Map<String, dynamic>> registerAdmin({
    required String orgName,
    required String orgCode,
    required String adminName,
    required String adminCompanyId,
    required String password,
    String address = '',
    String description = '',
    String email = '',
  }) async {
    try {
      final cleanOrg = orgCode.trim().toUpperCase();
      final cleanId = adminCompanyId.trim().toUpperCase();

      final orgDoc = await _db.collection('organizations').doc(cleanOrg).get();
      if (orgDoc.exists) {
        return {
          'success': false,
          'message': 'Organization code "$cleanOrg" already exists! Please choose another code.',
        };
      }

      // 1. Create Organization Document
      await _db.collection('organizations').doc(cleanOrg).set({
        'name': orgName.trim(),
        'orgCode': cleanOrg,
        'address': address.trim(),
        'description': description.trim(),
        'adminCompanyId': cleanId,
        'adminName': adminName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Create Admin User inside org
      final userModel = UserModel(
        id: cleanId,
        name: adminName.trim(),
        companyId: cleanId,
        email: email.trim(),
        role: 'ADMIN',
        department: 'Administration',
        orgId: cleanOrg,
      );

      await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('users')
          .doc(cleanId)
          .set({
        'name': adminName.trim(),
        'companyId': cleanId,
        'email': email.trim(),
        'role': 'ADMIN',
        'department': 'Administration',
        'passwordHash': hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Auto-whitelist admin
      await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('whitelist')
          .doc(cleanId)
          .set({
        'companyId': cleanId,
        'name': adminName.trim(),
        'department': 'Administration',
        'isRegistered': true,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      final orgModel = OrganizationModel(
        id: cleanOrg,
        name: orgName.trim(),
        orgCode: cleanOrg,
        address: address.trim(),
      );

      return {
        'success': true,
        'message': 'Organization portal created successfully on Firebase!',
        'user': userModel,
        'organization': orgModel,
      };
    } catch (e) {
      return {'success': false, 'message': 'Firebase Error: $e'};
    }
  }

  // 2. Admin Login
  static Future<Map<String, dynamic>> loginAdmin({
    required String orgCode,
    required String identifier,
    required String password,
  }) async {
    try {
      final cleanOrg = orgCode.trim().toUpperCase();
      final cleanId = identifier.trim().toUpperCase();

      final orgDoc = await _db.collection('organizations').doc(cleanOrg).get();
      if (!orgDoc.exists) {
        return {
          'success': false,
          'message': 'Organization "$cleanOrg" does not exist in Firebase.',
        };
      }

      final userDoc = await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('users')
          .doc(cleanId)
          .get();

      if (!userDoc.exists || userDoc.data()?['role'] != 'ADMIN') {
        return {
          'success': false,
          'message': 'Admin credentials not found for ID "$cleanId" in this organization.',
        };
      }

      final storedHash = userDoc.data()?['passwordHash'];
      if (storedHash != hashPassword(password)) {
        return {
          'success': false,
          'message': 'Incorrect password. Access denied.',
        };
      }

      final data = userDoc.data()!;
      final user = UserModel(
        id: cleanId,
        name: data['name'] ?? '',
        companyId: cleanId,
        email: data['email'] ?? '',
        role: 'ADMIN',
        department: data['department'] ?? 'Administration',
        orgId: cleanOrg,
      );

      final orgData = orgDoc.data()!;
      final organization = OrganizationModel(
        id: cleanOrg,
        name: orgData['name'] ?? '',
        orgCode: cleanOrg,
        address: orgData['address'] ?? '',
      );

      return {
        'success': true,
        'message': 'Admin login successful!',
        'user': user,
        'organization': organization,
      };
    } catch (e) {
      return {'success': false, 'message': 'Firebase Login Error: $e'};
    }
  }

  // 3. Verify Voter ID against Whitelist
  static Future<Map<String, dynamic>> verifyVoterId({
    required String orgCode,
    required String companyId,
  }) async {
    try {
      final cleanOrg = orgCode.trim().toUpperCase();
      final cleanId = companyId.trim().toUpperCase();

      final orgDoc = await _db.collection('organizations').doc(cleanOrg).get();
      if (!orgDoc.exists) {
        return {
          'success': false,
          'message': 'Organization "$cleanOrg" not found.',
        };
      }

      final wlDoc = await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('whitelist')
          .doc(cleanId)
          .get();

      if (!wlDoc.exists) {
        return {
          'success': false,
          'message': 'Access Denied! ID "$cleanId" is NOT whitelisted by ${orgDoc.data()?['name'] ?? 'Company'} admin. Outsiders are strictly not permitted.',
        };
      }

      if (wlDoc.data()?['isRegistered'] == true) {
        return {
          'success': false,
          'message': 'ID "$cleanId" is already registered! Please sign in with your password.',
        };
      }

      return {
        'success': true,
        'message': 'Verified! Your ID is authorized by the company admin.',
        'organization': {'name': orgDoc.data()?['name'] ?? cleanOrg, 'orgCode': cleanOrg},
        'prefilled': {
          'companyId': cleanId,
          'name': wlDoc.data()?['name'] ?? '',
          'department': wlDoc.data()?['department'] ?? '',
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Firebase Whitelist Error: $e'};
    }
  }

  // 4. Register Authorized Voter
  static Future<Map<String, dynamic>> registerVoter({
    required String orgCode,
    required String companyId,
    required String name,
    required String password,
    String department = '',
  }) async {
    try {
      final cleanOrg = orgCode.trim().toUpperCase();
      final cleanId = companyId.trim().toUpperCase();

      // Check Whitelist
      final wlDoc = await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('whitelist')
          .doc(cleanId)
          .get();

      if (!wlDoc.exists) {
        return {
          'success': false,
          'message': 'Access Denied! ID "$cleanId" is not on the company whitelist.',
        };
      }

      if (wlDoc.data()?['isRegistered'] == true) {
        return {
          'success': false,
          'message': 'This company ID is already registered.',
        };
      }

      // Create Voter User
      await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('users')
          .doc(cleanId)
          .set({
        'name': name.trim(),
        'companyId': cleanId,
        'department': department.trim(),
        'role': 'VOTER',
        'passwordHash': hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mark Whitelist as registered
      await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('whitelist')
          .doc(cleanId)
          .update({
        'isRegistered': true,
        'name': name.trim(),
        'department': department.trim(),
        'registeredAt': FieldValue.serverTimestamp(),
      });

      final orgDoc = await _db.collection('organizations').doc(cleanOrg).get();
      final orgName = orgDoc.data()?['name'] ?? cleanOrg;

      final user = UserModel(
        id: cleanId,
        name: name.trim(),
        companyId: cleanId,
        email: '',
        role: 'VOTER',
        department: department.trim(),
        orgId: cleanOrg,
      );

      final organization = OrganizationModel(
        id: cleanOrg,
        name: orgName,
        orgCode: cleanOrg,
      );

      return {
        'success': true,
        'message': 'Voter registration successful!',
        'user': user,
        'organization': organization,
      };
    } catch (e) {
      return {'success': false, 'message': 'Voter Register Error: $e'};
    }
  }

  // 5. Voter Login
  static Future<Map<String, dynamic>> loginVoter({
    required String orgCode,
    required String companyId,
    required String password,
  }) async {
    try {
      final cleanOrg = orgCode.trim().toUpperCase();
      final cleanId = companyId.trim().toUpperCase();

      final orgDoc = await _db.collection('organizations').doc(cleanOrg).get();
      if (!orgDoc.exists) {
        return {
          'success': false,
          'message': 'Organization "$cleanOrg" not found.',
        };
      }

      final userDoc = await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('users')
          .doc(cleanId)
          .get();

      if (!userDoc.exists || userDoc.data()?['role'] != 'VOTER') {
        return {
          'success': false,
          'message': 'No registered voter account found for ID "$cleanId".',
        };
      }

      final storedHash = userDoc.data()?['passwordHash'];
      if (storedHash != hashPassword(password)) {
        return {
          'success': false,
          'message': 'Incorrect password.',
        };
      }

      final data = userDoc.data()!;
      final user = UserModel(
        id: cleanId,
        name: data['name'] ?? '',
        companyId: cleanId,
        email: data['email'] ?? '',
        role: 'VOTER',
        department: data['department'] ?? '',
        orgId: cleanOrg,
      );

      final orgData = orgDoc.data()!;
      final organization = OrganizationModel(
        id: cleanOrg,
        name: orgData['name'] ?? '',
        orgCode: cleanOrg,
      );

      return {
        'success': true,
        'message': 'Voter sign in successful!',
        'user': user,
        'organization': organization,
      };
    } catch (e) {
      return {'success': false, 'message': 'Login Error: $e'};
    }
  }

  // -------------------------------------------------------------
  // WHITELIST MANAGEMENT (ADMIN)
  // -------------------------------------------------------------

  static Stream<List<WhitelistModel>> streamWhitelist(String orgCode) {
    return _db
        .collection('organizations')
        .doc(orgCode.toUpperCase())
        .collection('whitelist')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => WhitelistModel.fromJson({
              'id': doc.id,
              ...doc.data(),
              'createdAt': (doc.data()['registeredAt'] as Timestamp?)?.toDate().toIso8601String(),
            })).toList());
  }

  static Future<bool> addSingleWhitelistId({
    required String orgCode,
    required String companyId,
    String name = '',
    String department = '',
  }) async {
    try {
      final cleanOrg = orgCode.toUpperCase();
      final cleanId = companyId.trim().toUpperCase();

      await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('whitelist')
          .doc(cleanId)
          .set({
        'companyId': cleanId,
        'name': name.trim(),
        'department': department.trim(),
        'isRegistered': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> addBulkWhitelistIds({
    required String orgCode,
    required String rawIds,
  }) async {
    try {
      final cleanOrg = orgCode.toUpperCase();
      final tokens = rawIds
          .split(RegExp(r'[\r\n,;]+'))
          .map((t) => t.trim().toUpperCase())
          .where((t) => t.isNotEmpty)
          .toList();

      final batch = _db.batch();
      for (final id in tokens) {
        final docRef = _db.collection('organizations').doc(cleanOrg).collection('whitelist').doc(id);
        batch.set(docRef, {
          'companyId': id,
          'name': '',
          'department': '',
          'isRegistered': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteWhitelistId({
    required String orgCode,
    required String id,
  }) async {
    try {
      await _db
          .collection('organizations')
          .doc(orgCode.toUpperCase())
          .collection('whitelist')
          .doc(id.toUpperCase())
          .delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // ELECTIONS & VOTING (REAL-TIME FIRESTORE)
  // -------------------------------------------------------------

  static Stream<List<ElectionModel>> streamElections(String orgCode, String voterCompanyId) {
    return _db
        .collection('organizations')
        .doc(orgCode.toUpperCase())
        .collection('elections')
        .snapshots()
        .asyncMap((snap) async {
      final list = <ElectionModel>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final electionId = doc.id;

        bool hasVoted = false;
        String? receipt;
        final cleanVoterId = voterCompanyId.trim().toUpperCase();

        if (cleanVoterId.isNotEmpty) {
          try {
            final voteDoc = await _db
                .collection('organizations')
                .doc(orgCode.toUpperCase())
                .collection('elections')
                .doc(electionId)
                .collection('votes')
                .doc(cleanVoterId)
                .get();

            hasVoted = voteDoc.exists;
            receipt = voteDoc.data()?['voteReceiptHash'];
          } catch (_) {}
        }

        final el = _parseElection(doc.id, data, hasVoted, receipt);
        list.add(el);
      }

      list.sort((a, b) => b.startTime.compareTo(a.startTime));
      return list;
    });
  }

  static Future<ElectionModel?> getElectionById(String orgCode, String electionId, String voterCompanyId) async {
    try {
      final doc = await _db
          .collection('organizations')
          .doc(orgCode.toUpperCase())
          .collection('elections')
          .doc(electionId)
          .get();

      if (!doc.exists) return null;

      bool hasVoted = false;
      String? receipt;
      final cleanVoterId = voterCompanyId.trim().toUpperCase();

      if (cleanVoterId.isNotEmpty) {
        try {
          final voteDoc = await _db
              .collection('organizations')
              .doc(orgCode.toUpperCase())
              .collection('elections')
              .doc(electionId)
              .collection('votes')
              .doc(cleanVoterId)
              .get();

          hasVoted = voteDoc.exists;
          receipt = voteDoc.data()?['voteReceiptHash'];
        } catch (_) {}
      }

      return _parseElection(doc.id, doc.data()!, hasVoted, receipt);
    } catch (_) {
      return null;
    }
  }

  static ElectionModel _parseElection(String id, Map<String, dynamic> data, bool hasVoted, String? receipt) {
    try {
      DateTime startTime = DateTime.now();
      if (data['startTime'] is Timestamp) {
        startTime = (data['startTime'] as Timestamp).toDate();
      } else if (data['startTime'] is String) {
        startTime = DateTime.tryParse(data['startTime']) ?? DateTime.now();
      }

      DateTime endTime = DateTime.now().add(const Duration(hours: 4));
      if (data['endTime'] is Timestamp) {
        endTime = (data['endTime'] as Timestamp).toDate();
      } else if (data['endTime'] is String) {
        endTime = DateTime.tryParse(data['endTime']) ?? DateTime.now();
      }

      final isManualClosed = data['isManualClosed'] == true;

      String status = 'UPCOMING';
      final now = DateTime.now();
      if (isManualClosed || now.isAfter(endTime)) {
        status = 'COMPLETED';
      } else if (now.isAfter(startTime)) {
        status = 'ACTIVE';
      }

      final rawCandidates = (data['candidates'] as List? ?? []);
      final totalVotes = (data['totalVotes'] is num)
          ? (data['totalVotes'] as num).toInt()
          : int.tryParse(data['totalVotes']?.toString() ?? '0') ?? 0;

      int maxVotes = -1;
      CandidateModel? winner;
      bool isTie = false;

      final candidates = rawCandidates.map((c) {
        final cMap = <String, dynamic>{};
        if (c is Map) {
          c.forEach((k, v) => cMap[k.toString()] = v);
        }
        final cand = CandidateModel.fromJson(cMap);
        final percentage = totalVotes > 0 ? (cand.voteCount / totalVotes) * 100 : 0.0;
        final enriched = CandidateModel(
          id: cand.id,
          name: cand.name,
          companyId: cand.companyId,
          photoUrl: cand.photoUrl,
          logoUrl: cand.logoUrl,
          symbolName: cand.symbolName,
          bio: cand.bio,
          voteCount: cand.voteCount,
          votePercentage: percentage,
        );

        if (cand.voteCount > maxVotes) {
          maxVotes = cand.voteCount;
          winner = enriched;
          isTie = false;
        } else if (cand.voteCount == maxVotes && maxVotes > 0) {
          isTie = true;
        }
        return enriched;
      }).toList();

      return ElectionModel(
        id: id,
        title: (data['title'] ?? '').toString(),
        category: (data['category'] ?? '').toString(),
        description: (data['description'] ?? '').toString(),
        startTime: startTime,
        endTime: endTime,
        candidates: candidates,
        totalVotes: totalVotes,
        status: status,
        hasVoted: hasVoted,
        voteReceipt: receipt,
        isManualClosed: isManualClosed,
        winner: totalVotes > 0 && !isTie ? winner : null,
        isTie: totalVotes > 0 ? isTie : false,
      );
    } catch (e, stack) {
      print('PARSE ELECTION ERROR: $e\n$stack');
      return ElectionModel(
        id: id,
        title: (data['title'] ?? 'Election').toString(),
        category: (data['category'] ?? 'General').toString(),
        description: (data['description'] ?? '').toString(),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        candidates: [],
        status: 'ACTIVE',
      );
    }
  }

  // Create Election
  static Future<bool> createElection({
    required String orgCode,
    required String title,
    required String category,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> candidates,
  }) async {
    try {
      final cleanOrg = orgCode.toUpperCase();
      final formattedCandidates = candidates.asMap().entries.map((entry) {
        final idx = entry.key;
        final c = entry.value;
        return {
          'id': 'cand_${idx + 1}',
          'name': (c['name'] ?? '').toString().trim(),
          'companyId': (c['companyId'] ?? '').toString().trim().toUpperCase(),
          'photoUrl': (c['photoUrl'] ?? '').toString().trim(),
          'logoUrl': (c['logoUrl'] ?? '').toString().trim(),
          'symbolName': (c['symbolName'] ?? '').toString().trim(),
          'bio': (c['bio'] ?? '').toString().trim(),
          'voteCount': 0,
        };
      }).toList();

      await _db
          .collection('organizations')
          .doc(cleanOrg)
          .collection('elections')
          .add({
        'title': title.trim(),
        'category': category.trim(),
        'description': description.trim(),
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'candidates': formattedCandidates,
        'totalVotes': 0,
        'isManualClosed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  // Cast Vote with Firestore Transaction
  static Future<Map<String, dynamic>> castVote({
    required String orgCode,
    required String electionId,
    required String voterCompanyId,
    required String candidateId,
  }) async {
    try {
      final cleanOrg = orgCode.toUpperCase();
      final cleanVoter = voterCompanyId.toUpperCase();

      final electionRef = _db.collection('organizations').doc(cleanOrg).collection('elections').doc(electionId);
      final voteRef = electionRef.collection('votes').doc(cleanVoter);

      final result = await _db.runTransaction((transaction) async {
        final electionSnap = await transaction.get(electionRef);
        if (!electionSnap.exists) {
          return {'success': false, 'message': 'Election not found.'};
        }

        final voteSnap = await transaction.get(voteRef);
        if (voteSnap.exists) {
          return {
            'success': false,
            'message': 'You have already voted in this election!',
            'receipt': voteSnap.data()?['voteReceiptHash'],
          };
        }

        final data = electionSnap.data()!;
        final endTime = (data['endTime'] as Timestamp).toDate();
        final isManualClosed = data['isManualClosed'] == true;

        if (isManualClosed || DateTime.now().isAfter(endTime)) {
          return {'success': false, 'message': 'Voting time has ended.'};
        }

        final receipt = generateReceipt(cleanOrg, electionId, cleanVoter, candidateId);

        // Update candidate vote count
        final rawCandidates = List<Map<String, dynamic>>.from(data['candidates'] ?? []);
        String candidateName = '';
        for (final c in rawCandidates) {
          if (c['id'] == candidateId) {
            c['voteCount'] = (c['voteCount'] ?? 0) + 1;
            candidateName = c['name'] ?? '';
            break;
          }
        }

        // 1. Save Vote Document
        transaction.set(voteRef, {
          'candidateId': candidateId,
          'voterCompanyId': cleanVoter,
          'voteReceiptHash': receipt,
          'votedAt': FieldValue.serverTimestamp(),
        });

        // 2. Increment Election Totals
        transaction.update(electionRef, {
          'candidates': rawCandidates,
          'totalVotes': FieldValue.increment(1),
        });

        return {
          'success': true,
          'message': 'Vote cast successfully!',
          'receipt': receipt,
          'candidateName': candidateName,
          'electionTitle': (data['title'] ?? 'Corporate Election').toString(),
        };
      });

      if (result['success'] == true) {
        // Record Block onto Blockchain Ledger
        try {
          await BlockchainService.recordVoteBlock(
            orgCode: cleanOrg,
            electionId: electionId,
            electionTitle: result['electionTitle']?.toString() ?? 'Corporate Election',
            candidateId: candidateId,
            candidateName: result['candidateName']?.toString() ?? 'Candidate',
            voterCompanyId: cleanVoter,
            receiptCode: result['receipt']?.toString() ?? '',
          );
        } catch (_) {}
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Firebase Transaction Error: $e'};
    }
  }

  // Conclude Election Early
  static Future<bool> closeElectionEarly(String orgCode, String electionId) async {
    try {
      await _db
          .collection('organizations')
          .doc(orgCode.toUpperCase())
          .collection('elections')
          .doc(electionId)
          .update({
        'isManualClosed': true,
        'endTime': Timestamp.now(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // Delete Election
  static Future<bool> deleteElection(String orgCode, String electionId) async {
    try {
      await _db
          .collection('organizations')
          .doc(orgCode.toUpperCase())
          .collection('elections')
          .doc(electionId)
          .delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Dashboard Stats
  static Future<DashboardStatsModel> getDashboardStats(String orgCode) async {
    try {
      final cleanOrg = orgCode.toUpperCase();

      final wlSnap = await _db.collection('organizations').doc(cleanOrg).collection('whitelist').get();
      final totalWhitelisted = wlSnap.docs.length;
      final registeredVoters = wlSnap.docs.where((d) => d.data()['isRegistered'] == true).length;
      final pendingVoters = totalWhitelisted - registeredVoters;

      final electionsSnap = await _db.collection('organizations').doc(cleanOrg).collection('elections').get();
      int active = 0;
      int upcoming = 0;
      int completed = 0;
      int totalVotes = 0;

      final now = DateTime.now();
      for (final doc in electionsSnap.docs) {
        final data = doc.data();
        totalVotes += (data['totalVotes'] ?? 0) as int;
        final start = (data['startTime'] as Timestamp?)?.toDate() ?? now;
        final end = (data['endTime'] as Timestamp?)?.toDate() ?? now;
        final isClosed = data['isManualClosed'] == true;

        if (isClosed || now.isAfter(end)) {
          completed++;
        } else if (now.isBefore(start)) {
          upcoming++;
        } else {
          active++;
        }
      }

      final turnout = registeredVoters > 0 && electionsSnap.docs.isNotEmpty
          ? (totalVotes / (registeredVoters * electionsSnap.docs.length)) * 100
          : 0.0;

      return DashboardStatsModel(
        totalWhitelisted: totalWhitelisted,
        registeredVoters: registeredVoters,
        pendingVoters: pendingVoters,
        totalElections: electionsSnap.docs.length,
        activeElections: active,
        upcomingElections: upcoming,
        completedElections: completed,
        totalVotesCast: totalVotes,
        turnoutRate: turnout,
      );
    } catch (_) {
      return DashboardStatsModel();
    }
  }
}

extension IterableExt<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T) test) => where(test);
}
