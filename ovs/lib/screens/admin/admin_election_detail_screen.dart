import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/election_model.dart';
import '../../providers/election_provider.dart';
import '../../widgets/candidate_tile.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class AdminElectionDetailScreen extends StatefulWidget {
  final String electionId;

  const AdminElectionDetailScreen({super.key, required this.electionId});

  @override
  State<AdminElectionDetailScreen> createState() => _AdminElectionDetailScreenState();
}

class _AdminElectionDetailScreenState extends State<AdminElectionDetailScreen> {
  ElectionModel? _election;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElection();
  }

  Future<void> _loadElection() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<ElectionProvider>(context, listen: false);
    final el = await provider.fetchElectionById(widget.electionId);
    if (mounted) {
      setState(() {
        _election = el;
        _isLoading = false;
      });
    }
  }

  Future<void> _closeElectionEarly() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conclude Election Early?'),
        content: const Text(
          'Closing this election now will immediately stop further voting and finalize the results with current vote counts.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End & Publish Results'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ElectionProvider>(context, listen: false);
      final success = await provider.closeElection(widget.electionId);
      if (success) {
        _loadElection();
      }
    }
  }

  Future<void> _deleteElection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Election Permanently?'),
        content: const Text(
          'This will permanently delete this election and all cast votes from your company portal database. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ElectionProvider>(context, listen: false);
      final success = await provider.deleteElection(widget.electionId);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Election Portal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_election == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Election Portal')),
        body: const Center(child: Text('Election not found')),
      );
    }

    final el = _election!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Monitor & Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Live Refresh',
            onPressed: _loadElection,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
            tooltip: 'Delete Election',
            onPressed: _deleteElection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Category
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                ),
                const Spacer(),
                StatusBadge(status: el.status),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              el.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textMain),
            ),
            if (el.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                el.description,
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4),
              ),
            ],

            const SizedBox(height: 18),

            // Live Countdown / Timeline Banner
            if (el.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Voting Active', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                        Text('Votes are being recorded in real-time', style: TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                      ],
                    ),
                    CountdownTimerWidget(
                      targetTime: el.endTime,
                      onFinished: _loadElection,
                    ),
                  ],
                ),
              ),

            // Winner Announcement Banner (if completed)
            if (el.isCompleted) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, size: 30, color: Colors.amber),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OFFICIAL RESULT DECLARED',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            el.isTie
                                ? 'Election Ended in a TIE!'
                                : (el.winner != null ? '${el.winner!.name} WON!' : 'No Votes Recorded'),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          if (el.winner != null)
                            Text(
                              'Total: ${el.winner!.voteCount} votes (${el.winner!.votePercentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Schedule Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Starts: ${dateFormat.format(el.startTime)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.event_available_outlined, size: 16, color: AppTheme.danger),
                        const SizedBox(width: 8),
                        Text(
                          'Ends:   ${dateFormat.format(el.endTime)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Turnout / Ballots Cast:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          '${el.totalVotes} Votes',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Real-Time Candidates Tally
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CANDIDATES & LIVE STANDINGS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.5),
                ),
                Text(
                  '${el.candidates.length} Nominees',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const Divider(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: el.candidates.length,
              itemBuilder: (ctx, idx) {
                final cand = el.candidates[idx];
                final isWinner = el.isCompleted && el.winner?.id == cand.id && !el.isTie;

                return CandidateTile(
                  candidate: cand,
                  showResults: true,
                  isWinner: isWinner,
                );
              },
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (el.isActive) ...[
              CustomButton(
                text: 'Conclude Election & Finalize Now',
                icon: Icons.stop_circle_outlined,
                backgroundColor: AppTheme.danger,
                onPressed: _closeElectionEarly,
              ),
              const SizedBox(height: 12),
            ],

            CustomButton(
              text: 'Delete Election Record',
              icon: Icons.delete_outline,
              isOutlined: true,
              textColor: AppTheme.danger,
              backgroundColor: AppTheme.danger,
              onPressed: _deleteElection,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
