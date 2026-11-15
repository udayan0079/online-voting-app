import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/election_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../auth/role_select_screen.dart';
import 'create_election_screen.dart';
import 'manage_whitelist_screen.dart';
import 'admin_election_detail_screen.dart';
import '../help/how_to_use_screen.dart';
import 'admin_ai_chatbot_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final electionProvider = Provider.of<ElectionProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);

    await Future.wait([
      electionProvider.fetchElections(),
      analyticsProvider.fetchDashboardStats(),
    ]);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of the Admin Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
    final analytics = Provider.of<AnalyticsProvider>(context);

    final org = auth.currentOrg;
    final user = auth.currentUser;
    final stats = analytics.stats;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              org?.name ?? 'Admin Portal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            if (org?.orgCode != null)
              Text(
                'PORTAL CODE: ${org!.orgCode}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Admin Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAiChatbotScreen()),
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.danger),
            tooltip: 'Sign Out',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_ai_assistant_fab',
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
        label: const Text(
          'AI Assistant',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
        ),
        backgroundColor: AppTheme.accentIndigo,
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAiChatbotScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Greeting Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? "Administrator"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Organization: ${org?.name ?? "N/A"}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New Election', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            onPressed: () async {
                              final created = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateElectionScreen()),
                              );
                              if (created == true) _loadDashboardData();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.people_alt_outlined, size: 18),
                            label: const Text('Voter Whitelist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ManageWhitelistScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Assistant Quick Help Card
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAiChatbotScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentIndigo.withOpacity(0.25), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentIndigo.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentIndigo.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.smart_toy_rounded, color: AppTheme.accentIndigo, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Facing any problem? Ask AI Bot',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.textMain,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Real-time step-by-step troubleshooting assistant',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.accentIndigo),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Overview Metrics Row
              const Text(
                'PORTAL OVERVIEW',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Authorized IDs',
                      value: stats.totalWhitelisted.toString(),
                      icon: Icons.badge_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Registered',
                      value: stats.registeredVoters.toString(),
                      icon: Icons.how_to_reg,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Votes Cast',
                      value: stats.totalVotesCast.toString(),
                      icon: Icons.check_circle_outline,
                      color: AppTheme.accentIndigo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Elections Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ELECTIONS & POLLS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Election', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateElectionScreen()),
                      );
                      if (created == true) _loadDashboardData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All (${electionProvider.elections.length})'),
                    _buildFilterChip('ACTIVE', 'Live (${electionProvider.activeElections.length})'),
                    _buildFilterChip('UPCOMING', 'Upcoming (${electionProvider.upcomingElections.length})'),
                    _buildFilterChip('COMPLETED', 'Concluded (${electionProvider.completedElections.length})'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Elections List
              if (electionProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_filteredElections(electionProvider).isEmpty)
                EmptyStateWidget(
                  icon: Icons.how_to_vote_outlined,
                  title: 'No Elections Found',
                  subtitle: 'Create a voting session for any role like HR, CR, President, or Prime Minister.',
                  buttonText: 'Create First Election',
                  onButtonPressed: () async {
                    final created = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateElectionScreen()),
                    );
                    if (created == true) _loadDashboardData();
                  },
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredElections(electionProvider).length,
                  itemBuilder: (ctx, index) {
                    final election = _filteredElections(electionProvider)[index];
                    return _buildElectionCard(context, election);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> _filteredElections(ElectionProvider provider) {
    switch (provider.currentFilter) {
      case 'ACTIVE':
        return provider.activeElections;
      case 'UPCOMING':
        return provider.upcomingElections;
      case 'COMPLETED':
        return provider.completedElections;
      default:
        return provider.elections;
    }
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final provider = Provider.of<ElectionProvider>(context);
    final isSelected = provider.currentFilter == filterKey;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textMain,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primary,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => provider.setFilter(filterKey),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectionCard(BuildContext context, dynamic election) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminElectionDetailScreen(electionId: election.id),
              ),
            );
            _loadDashboardData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        election.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: election.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  election.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
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

                // Candidates and Votes Summary
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 15, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${election.candidates.length} Candidates',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.how_to_vote_outlined, size: 15, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${election.totalVotes} Votes Cast',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.textMuted),
                  ],
                ),

                if (election.isActive) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Voting Session',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success),
                      ),
                      CountdownTimerWidget(
                        targetTime: election.endTime,
                        label: 'Ends In',
                        onFinished: () {
                          _loadDashboardData();
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
