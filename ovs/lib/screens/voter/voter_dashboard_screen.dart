import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/election_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/election_provider.dart';
import '../../providers/voting_provider.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../auth/role_select_screen.dart';
import 'voter_ballot_screen.dart';
import 'election_results_screen.dart';
import '../help/how_to_use_screen.dart';
import '../blockchain/blockchain_explorer_screen.dart';

class VoterDashboardScreen extends StatefulWidget {
  const VoterDashboardScreen({super.key});

  @override
  State<VoterDashboardScreen> createState() => _VoterDashboardScreenState();
}

class _VoterDashboardScreenState extends State<VoterDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElections();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadElections() async {
    final provider = Provider.of<ElectionProvider>(context, listen: false);
    await provider.fetchElections();
  }

  void _showVerifyReceiptDialog() {
    final receiptController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Vote Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your cryptographic receipt code (e.g., VOTE-XXXX) to verify that your ballot is securely stored in the audit ledger.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: receiptController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'VOTE-XXXXXXXX',
                labelText: 'Receipt Code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (receiptController.text.trim().isEmpty) return;
              final votingProvider = Provider.of<VotingProvider>(context, listen: false);
              final result = await votingProvider.verifyReceipt(receiptController.text.trim());

              if (mounted) {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (rCtx) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          result['success'] == true ? Icons.check_circle : Icons.error_outline,
                          color: result['success'] == true ? AppTheme.success : AppTheme.danger,
                        ),
                        const SizedBox(width: 8),
                        Text(result['success'] == true ? 'Receipt Verified' : 'Receipt Not Found'),
                      ],
                    ),
                    content: Text(
                      result['message'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    actions: [
                      ElevatedButton(onPressed: () => Navigator.pop(rCtx), child: const Text('OK')),
                    ],
                  ),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of the Voter Portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final electionProvider = Provider.of<ElectionProvider>(context);

    final org = auth.currentOrg;
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              org?.name ?? 'SmartVote Portal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'ORG: ${org?.orgCode ?? "PORTAL"}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded, color: Color(0xFF0284C7)),
            tooltip: 'Blockchain Explorer',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockchainExplorerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to Use / User Guide',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HowToUseScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Verify Vote Receipt',
            onPressed: _showVerifyReceiptDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadElections,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.danger),
            tooltip: 'Sign Out',
            onPressed: _confirmLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Live Polls (${electionProvider.activeElections.length})'),
            Tab(text: 'Upcoming (${electionProvider.upcomingElections.length})'),
            Tab(text: 'Results (${electionProvider.completedElections.length})'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Voter Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'V',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Authorized Voter',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                        ),
                        Text(
                          'Company ID: ${user?.companyId ?? "N/A"}${user?.department.isNotEmpty == true ? " • ${user!.department}" : ""}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, size: 12, color: Color(0xFF15803D)),
                        SizedBox(width: 4),
                        Text(
                          'AUTHORIZED',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadElections,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildElectionsTab(electionProvider.activeElections, 'No live voting sessions open right now.'),
                    _buildElectionsTab(electionProvider.upcomingElections, 'No upcoming elections scheduled.'),
                    _buildElectionsTab(electionProvider.completedElections, 'No past election results available yet.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectionsTab(List<ElectionModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.how_to_vote_outlined,
        title: 'No Elections Available',
        subtitle: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: list.length,
      itemBuilder: (ctx, index) {
        final election = list[index];
        return _buildVoterElectionCard(election);
      },
    );
  }

  Widget _buildVoterElectionCard(ElectionModel election) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    election.category.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                ),
                const Spacer(),
                StatusBadge(status: election.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              election.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textMain),
            ),
            if (election.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                election.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
            const SizedBox(height: 14),

            // Live Timer if Active
            if (election.isActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CountdownTimerWidget(
                    targetTime: election.endTime,
                    label: 'Voting Closes In',
                    onFinished: _loadElections,
                  ),
                  if (election.hasVoted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: AppTheme.success),
                          SizedBox(width: 4),
                          Text('Voted ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Candidates Count & Secret Ballot Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline, size: 15, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        '${election.candidates.length} Candidates',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 12, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text(
                          'Secret Ballot',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Candidate chips preview
              if (election.candidates.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: election.candidates.take(3).map((cand) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: AppTheme.primary.withOpacity(0.15),
                            child: Text(
                              cand.name.isNotEmpty ? cand.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(width: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              cand.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                            ),
                          ),
                          if (cand.symbolName.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${cand.symbolName})',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accent),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 14),
            ],

            // Action Buttons
            if (election.isActive) ...[
              if (election.hasVoted) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: Text(
                      election.voteReceipt != null ? 'View Receipt (${election.voteReceipt})' : 'Vote Submitted',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      if (election.voteReceipt != null) {
                        _showReceiptModal(election.voteReceipt!);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 13, color: AppTheme.success),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Your vote is encrypted and securely sealed on ledger.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.how_to_vote, size: 18),
                    label: const Text('Cast Your Vote Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      final voted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoterBallotScreen(electionId: election.id),
                        ),
                      );
                      if (voted == true) _loadElections();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 13, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Confidential & Anonymous • One Vote Per Employee',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (election.isCompleted) ...[
              // Candidate & Vote Count info
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${election.candidates.length} Candidates',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.how_to_vote_outlined, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${election.totalVotes} Total Votes',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                  ),
                ],
              ),
              if (election.winner != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Text(
                        'Winner: ${election.winner!.name}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                      ),
                      if (election.winner!.symbolName.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${election.winner!.symbolName})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.bar_chart, size: 18),
                  label: const Text(
                    'View Official Results & Winner',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ElectionResultsScreen(electionId: election.id),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Opens at: ${election.startTime.toLocal().toString().substring(0, 16)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReceiptModal(String receipt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Cryptographic Vote Receipt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your ballot was verified and sealed onto the organization database ledger:',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                receipt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
