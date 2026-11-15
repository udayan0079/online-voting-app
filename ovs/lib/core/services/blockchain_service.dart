import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/blockchain_model.dart';

class BlockchainService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream real-time blockchain blocks for an organization
  static Stream<List<BlockchainBlock>> streamChain(String orgCode) {
    final cleanOrg = orgCode.trim().toUpperCase();
    return _db
        .collection('organizations')
        .doc(cleanOrg)
        .collection('blockchain')
        .orderBy('index', descending: false)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BlockchainBlock.fromJson(data);
      }).toList();
    });
  }

  /// Ensure Genesis Block exists for an organization
  static Future<BlockchainBlock> ensureGenesisBlock(String orgCode) async {
    final cleanOrg = orgCode.trim().toUpperCase();
    final genesisDoc = await _db
        .collection('organizations')
        .doc(cleanOrg)
        .collection('blockchain')
        .doc('block_0')
        .get();

    if (genesisDoc.exists && genesisDoc.data() != null) {
      return BlockchainBlock.fromJson(genesisDoc.data()!);
    }

    final genesisBlock = BlockchainBlock.createGenesisBlock(orgCode: cleanOrg);
    await _db
        .collection('organizations')
        .doc(cleanOrg)
        .collection('blockchain')
        .doc('block_0')
        .set(genesisBlock.toJson());

    return genesisBlock;
  }

  /// Mine and add a vote block to the blockchain ledger
  static Future<BlockchainBlock> recordVoteBlock({
    required String orgCode,
    required String electionId,
    required String electionTitle,
    required String candidateId,
    required String candidateName,
    required String voterCompanyId,
    required String receiptCode,
  }) async {
    final cleanOrg = orgCode.trim().toUpperCase();
    await ensureGenesisBlock(cleanOrg);

    // Get the latest block in chain
    final latestDocs = await _db
        .collection('organizations')
        .doc(cleanOrg)
        .collection('blockchain')
        .orderBy('index', descending: true)
        .limit(1)
        .get();

    BlockchainBlock latestBlock;
    if (latestDocs.docs.isNotEmpty) {
      latestBlock = BlockchainBlock.fromJson(latestDocs.docs.first.data());
    } else {
      latestBlock = await ensureGenesisBlock(cleanOrg);
    }

    final newIndex = latestBlock.index + 1;
    final voteData = {
      'type': 'BALLOT_CAST',
      'electionId': electionId,
      'electionTitle': electionTitle,
      'candidateId': candidateId,
      'candidateName': candidateName,
      'receiptCode': receiptCode,
      'voterCompanyId': voterCompanyId.toUpperCase(),
      'orgCode': cleanOrg,
    };

    final newBlock = BlockchainBlock.mineBlock(
      index: newIndex,
      previousHash: latestBlock.hash,
      voteData: voteData,
      difficulty: 1,
    );

    await _db
        .collection('organizations')
        .doc(cleanOrg)
        .collection('blockchain')
        .doc('block_$newIndex')
        .set(newBlock.toJson());

    return newBlock;
  }

  /// Cryptographic Audit Validator: Verifies the integrity of the entire blockchain
  static Map<String, dynamic> verifyChainIntegrity(List<BlockchainBlock> chain) {
    if (chain.isEmpty) {
      return {
        'isValid': true,
        'totalBlocks': 0,
        'message': 'Blockchain is currently empty. Ready to record votes.',
        'tamperedBlock': -1,
      };
    }

    // 1. Verify Genesis Block
    final genesis = chain[0];
    if (genesis.index != 0 || !genesis.isValid()) {
      return {
        'isValid': false,
        'totalBlocks': chain.length,
        'message': 'Genesis Block (#0) has been tampered with or corrupted!',
        'tamperedBlock': 0,
      };
    }

    // 2. Verify all subsequent blocks in sequence
    for (int i = 1; i < chain.length; i++) {
      final current = chain[i];
      final previous = chain[i - 1];

      // Check block hash calculation
      if (!current.isValid()) {
        return {
          'isValid': false,
          'totalBlocks': chain.length,
          'message': 'Block #${current.index} hash integrity check failed! Payload was modified.',
          'tamperedBlock': current.index,
        };
      }

      // Check link to previous block
      if (current.previousHash != previous.hash) {
        return {
          'isValid': false,
          'totalBlocks': chain.length,
          'message': 'Broken chain link at Block #${current.index}! Previous hash does not match Block #${previous.index} hash.',
          'tamperedBlock': current.index,
        };
      }
    }

    return {
      'isValid': true,
      'totalBlocks': chain.length,
      'message': 'All ${chain.length} blocks cryptographically verified! 100% Immutable and tamper-proof.',
      'tamperedBlock': -1,
    };
  }
}
