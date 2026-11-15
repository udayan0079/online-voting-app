import 'dart:convert';
import 'package:crypto/crypto.dart';

class BlockchainBlock {
  final int index;
  final DateTime timestamp;
  final String previousHash;
  final Map<String, dynamic> voteData;
  final int nonce;
  final String hash;

  BlockchainBlock({
    required this.index,
    required this.timestamp,
    required this.previousHash,
    required this.voteData,
    required this.nonce,
    required this.hash,
  });

  /// Cryptographic SHA-256 hash calculator for block integrity
  static String calculateHash({
    required int index,
    required String previousHash,
    required DateTime timestamp,
    required Map<String, dynamic> voteData,
    required int nonce,
  }) {
    // Sort keys deterministically
    final sortedData = Map.fromEntries(
      voteData.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final raw = '$index$previousHash${timestamp.toIso8601String()}${jsonEncode(sortedData)}$nonce';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// Create Genesis Block (#0)
  static BlockchainBlock createGenesisBlock({required String orgCode}) {
    final now = DateTime.utc(2026, 1, 1);
    final genesisData = {
      'type': 'GENESIS_BLOCK',
      'orgCode': orgCode.toUpperCase(),
      'description': 'SmartVote Corporate Blockchain Ledger Genesis Block - Cryptographically Sealed',
      'network': 'SmartVote-Consensus-v1',
    };
    const prevHash = '0000000000000000000000000000000000000000000000000000000000000000';
    const nonce = 0;
    final hash = calculateHash(
      index: 0,
      previousHash: prevHash,
      timestamp: now,
      voteData: genesisData,
      nonce: nonce,
    );

    return BlockchainBlock(
      index: 0,
      timestamp: now,
      previousHash: prevHash,
      voteData: genesisData,
      nonce: nonce,
      hash: hash,
    );
  }

  /// Mine new Block with Proof-of-Work / Difficulty verification
  static BlockchainBlock mineBlock({
    required int index,
    required String previousHash,
    required Map<String, dynamic> voteData,
    int difficulty = 1, // Leading zero requirement
  }) {
    final timestamp = DateTime.now().toUtc();
    int nonce = 0;
    String hash = '';
    final targetPrefix = '0' * difficulty;

    while (true) {
      hash = calculateHash(
        index: index,
        previousHash: previousHash,
        timestamp: timestamp,
        voteData: voteData,
        nonce: nonce,
      );
      if (hash.startsWith(targetPrefix)) {
        break;
      }
      nonce++;
    }

    return BlockchainBlock(
      index: index,
      timestamp: timestamp,
      previousHash: previousHash,
      voteData: voteData,
      nonce: nonce,
      hash: hash,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'timestamp': timestamp.toIso8601String(),
        'previousHash': previousHash,
        'voteData': voteData,
        'nonce': nonce,
        'hash': hash,
      };

  factory BlockchainBlock.fromJson(Map<String, dynamic> json) {
    DateTime ts = DateTime.now();
    if (json['timestamp'] is String) {
      ts = DateTime.tryParse(json['timestamp']) ?? DateTime.now();
    } else if (json['timestamp'] != null) {
      ts = DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] is int ? json['timestamp'] : 0,
      );
    }

    return BlockchainBlock(
      index: json['index'] as int? ?? 0,
      timestamp: ts,
      previousHash: json['previousHash']?.toString() ?? '',
      voteData: json['voteData'] is Map
          ? Map<String, dynamic>.from(json['voteData'])
          : {},
      nonce: json['nonce'] as int? ?? 0,
      hash: json['hash']?.toString() ?? '',
    );
  }

  /// Verify if this block's cryptographic hash is authentic
  bool isValid() {
    final expected = calculateHash(
      index: index,
      previousHash: previousHash,
      timestamp: timestamp,
      voteData: voteData,
      nonce: nonce,
    );
    return expected == hash;
  }
}
