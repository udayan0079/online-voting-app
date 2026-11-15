import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/blockchain_service.dart';
import '../../models/blockchain_model.dart';
import '../../providers/auth_provider.dart';

class BlockchainExplorerScreen extends StatefulWidget {
  const BlockchainExplorerScreen({super.key});

  @override
  State<BlockchainExplorerScreen> createState() => _BlockchainExplorerScreenState();
}

class _BlockchainExplorerScreenState extends State<BlockchainExplorerScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _runIntegrityAudit(List<BlockchainBlock> chain) {
    final result = BlockchainService.verifyChainIntegrity(chain);
    final bool isValid = result['isValid'] == true;
    final int count = result['totalBlocks'] as int? ?? 0;
    final String message = result['message']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isValid ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
              color: isValid ? AppTheme.success : AppTheme.danger,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isValid ? 'Blockchain Verified' : 'Integrity Compromised!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isValid ? AppTheme.success : AppTheme.danger).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isValid ? AppTheme.success : AppTheme.danger).withOpacity(0.3),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isValid ? Colors.green.shade900 : Colors.red.shade900,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildAuditRow('Total Blocks Analyzed:', '$count Blocks'),
            _buildAuditRow('Hashing Algorithm:', 'SHA-256 Proof-of-Work'),
            _buildAuditRow('Chain Continuity:', isValid ? '100% Unbroken' : 'Broken Link Detected'),
            _buildAuditRow('Tamper Evidence:', isValid ? 'Zero Modifications' : 'Altered Ballot Found'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppTheme.primary : AppTheme.danger,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final org = auth.currentOrg;
    final orgCode = org?.orgCode ?? 'UDU007';

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blockchain Ledger Explorer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'ORG CODE: $orgCode • SHA-256 IMMUTABLE LEDGER',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accent),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<BlockchainBlock>>(
        stream: BlockchainService.streamChain(orgCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chain = snapshot.data ?? [];

          // Auto-init Genesis Block if none
          if (chain.isEmpty) {
            BlockchainService.ensureGenesisBlock(orgCode);
          }

          final filtered = chain.where((block) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            final receipt = block.voteData['receiptCode']?.toString().toLowerCase() ?? '';
            final candidate = block.voteData['candidateName']?.toString().toLowerCase() ?? '';
            final election = block.voteData['electionTitle']?.toString().toLowerCase() ?? '';
            final idxStr = block.index.toString();
            final hash = block.hash.toLowerCase();
            return receipt.contains(q) ||
                candidate.contains(q) ||
                election.contains(q) ||
                idxStr == q ||
                hash.contains(q);
          }).toList();

          return Column(
            children: [
              // Header Audit & Metrics Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.link_rounded, color: Color(0xFF38BDF8), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${chain.length} Blocks Sealed',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.success.withOpacity(0.5)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.lock, size: 10, color: AppTheme.success),
                                        SizedBox(width: 4),
                                        Text(
                                          'TAMPER-PROOF',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Consensus: Proof-of-Work SHA-256 Chained Hashes',
                                style: TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.security_update_good_rounded, size: 16),
                        label: const Text(
                          'Validate Entire Blockchain Integrity',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _runIntegrityAudit(chain),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search block by receipt (VOTE-XXX), candidate or block #...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),

              // Block List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              chain.isEmpty ? 'No blocks mined yet' : 'No matching block found',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, idx) {
                          final block = filtered[idx];
                          final isGenesis = block.index == 0;
                          return _buildBlockCard(block, isGenesis);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlockCard(BlockchainBlock block, bool isGenesis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGenesis ? const Color(0xFFF59E0B).withOpacity(0.5) : AppTheme.border,
          width: isGenesis ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isGenesis
                  ? const Color(0xFFF59E0B).withOpacity(0.08)
                  : const Color(0xFF2563EB).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isGenesis ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isGenesis ? 'BLOCK #0 (GENESIS)' : 'BLOCK #${block.index}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${block.timestamp.hour.toString().padLeft(2, '0')}:${block.timestamp.minute.toString().padLeft(2, '0')}:${block.timestamp.second.toString().padLeft(2, '0')} UTC • Nonce: ${block.nonce}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payload details
                if (isGenesis) ...[
                  const Text(
                    'Genesis Block Initialized',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    block.voteData['description']?.toString() ?? 'Network Initialized',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          block.voteData['electionTitle']?.toString() ?? 'Corporate Election',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Selected Candidate:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            Text(
                              block.voteData['candidateName']?.toString() ?? 'N/A',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Audit Receipt:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            Text(
                              block.voteData['receiptCode']?.toString() ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Hash & Previous Hash info
                _buildHashTile(
                  label: 'Block Hash (SHA-256):',
                  hash: block.hash,
                  highlight: true,
                ),
                const SizedBox(height: 4),
                _buildHashTile(
                  label: 'Previous Hash:',
                  hash: block.previousHash,
                  highlight: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashTile({required String label, required String hash, required bool highlight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: highlight ? AppTheme.primary : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: hash));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hash copied to clipboard!'), duration: Duration(seconds: 1)),
            );
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: highlight ? AppTheme.primary.withOpacity(0.04) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: highlight ? AppTheme.primary.withOpacity(0.2) : Colors.grey.shade300,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hash,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: highlight ? const Color(0xFF1E3A8A) : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, size: 12, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
