import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/candidate_model.dart';
import '../../models/election_model.dart';
import '../../providers/election_provider.dart';
import '../../providers/voting_provider.dart';
import '../../widgets/candidate_tile.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/custom_button.dart';
import 'voting_success_screen.dart';

class VoterBallotScreen extends StatefulWidget {
  final String electionId;

  const VoterBallotScreen({super.key, required this.electionId});

  @override
  State<VoterBallotScreen> createState() => _VoterBallotScreenState();
}

class _VoterBallotScreenState extends State<VoterBallotScreen> {
  ElectionModel? _election;
  CandidateModel? _selectedCandidate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBallot();
  }

  Future<void> _loadBallot() async {
    final provider = Provider.of<ElectionProvider>(context, listen: false);
    final el = await provider.fetchElectionById(widget.electionId);
    if (mounted) {
      setState(() {
        _election = el;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndCastVote() async {
    if (_selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a candidate before casting your vote.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Your Vote Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are casting your official vote for:',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCandidate!.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                  Text('ID: ${_selectedCandidate!.companyId}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  if (_selectedCandidate!.symbolName.isNotEmpty)
                    Text('Symbol: ${_selectedCandidate!.symbolName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Note: Once submitted, your vote is final, immutable, and cryptographically hashed onto the database ledger. You cannot change it.',
              style: TextStyle(fontSize: 11, color: AppTheme.danger),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm & Cast Vote'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final votingProvider = Provider.of<VotingProvider>(context, listen: false);
      final res = await votingProvider.castVote(
        electionId: _election!.id,
        candidateId: _selectedCandidate!.id,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VotingSuccessScreen(
              receipt: res['receipt'] ?? '',
              candidateName: _selectedCandidate!.name,
              electionTitle: _election!.title,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Failed to cast vote'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final votingProvider = Provider.of<VotingProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Official Ballot')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_election == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Official Ballot')),
        body: const Center(child: Text('Election ballot not found')),
      );
    }

    final el = _election!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Official Electronic Ballot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'POSITION: ${el.category.toUpperCase()}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                ),
                const Spacer(),
                CountdownTimerWidget(
                  targetTime: el.endTime,
                  label: 'Time Left',
                  onFinished: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voting time has expired!')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Election Title
            Text(
              el.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textMain),
            ),
            if (el.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                el.description,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
              ),
            ],

            const SizedBox(height: 20),

            // Instruction Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, size: 20, color: Color(0xFFB45309)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap on your chosen candidate below to select them, then press "Submit Ballot".',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'CANDIDATES ON THIS BALLOT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.5),
            ),
            const Divider(height: 14),

            // Candidates List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: el.candidates.length,
              itemBuilder: (ctx, index) {
                final cand = el.candidates[index];
                final isSelected = _selectedCandidate?.id == cand.id;

                return CandidateTile(
                  candidate: cand,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedCandidate = cand;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: _selectedCandidate != null
                  ? 'Submit Ballot for ${_selectedCandidate!.name}'
                  : 'Select a Candidate Above',
              isLoading: votingProvider.isSubmitting,
              icon: Icons.how_to_vote,
              onPressed: _selectedCandidate != null ? _confirmAndCastVote : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
