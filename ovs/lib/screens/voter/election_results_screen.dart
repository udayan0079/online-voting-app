import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/election_model.dart';
import '../../providers/election_provider.dart';
import '../../widgets/candidate_tile.dart';

class ElectionResultsScreen extends StatefulWidget {
  final String electionId;

  const ElectionResultsScreen({super.key, required this.electionId});

  @override
  State<ElectionResultsScreen> createState() => _ElectionResultsScreenState();
}

class _ElectionResultsScreenState extends State<ElectionResultsScreen> {
  ElectionModel? _election;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final provider = Provider.of<ElectionProvider>(context, listen: false);
    final el = await provider.fetchElectionById(widget.electionId);
    if (mounted) {
      setState(() {
        _election = el;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Official Results')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_election == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Official Results')),
        body: const Center(child: Text('Results not found')),
      );
    }

    final el = _election!;
    final winner = el.winner;

    // Sort candidates descending by votes
    final sortedCandidates = List.of(el.candidates)
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Official Certified Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    el.category.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, size: 13, color: Color(0xFF15803D)),
                      SizedBox(width: 4),
                      Text(
                        'FINAL RESULTS PUBLISHED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              el.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textMain),
            ),
            const SizedBox(height: 4),
            Text(
              'Election Concluded on ${dateFormat.format(el.endTime)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),

            const SizedBox(height: 20),

            // Winner Celebration Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2042), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'WINNER OF THE ELECTION',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.amber, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    el.isTie
                        ? 'TIE ELECTION!'
                        : (winner != null ? winner.name : 'No winner declared'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  if (winner != null && !el.isTie) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${winner.companyId} ${winner.symbolName.isNotEmpty ? "• Symbol: ${winner.symbolName}" : ""}',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${winner.voteCount} Votes (${winner.votePercentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Total votes summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Certified Turnout:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      '${el.totalVotes} Ballots Cast',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'FINAL CANDIDATE RANKINGS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.5),
            ),
            const Divider(height: 14),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedCandidates.length,
              itemBuilder: (ctx, index) {
                final cand = sortedCandidates[index];
                final isWinner = !el.isTie && winner?.id == cand.id;

                return CandidateTile(
                  candidate: cand,
                  showResults: true,
                  isWinner: isWinner,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
