import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/storage/storage_service.dart';
import 'admin_login_screen.dart';
import 'admin_register_screen.dart';
import 'voter_login_screen.dart';
import 'voter_register_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _showServerConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: StorageService.getBaseUrl());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Connection URL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the backend API URL. For Windows/Web: http://127.0.0.1:5000/api. For Android Emulator: http://10.0.2.2:5000/api. For physical mobile device over Wi-Fi: http://<Your-PC-IP>:5000/api',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base API URL',
                hintText: 'http://127.0.0.1:5000/api',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await StorageService.saveBaseUrl(controller.text.trim());
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Server URL updated!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textMuted),
            tooltip: 'Server Connection Config',
            onPressed: () => _showServerConfigDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo & Title
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.how_to_vote, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'SmartVote Corporate',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your portal to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 36),

              // Option 1: Voter Portal
              _buildRoleCard(
                context,
                title: 'Authorized Voter Portal',
                subtitle: 'Log in with your pre-approved Company/Employee ID to participate in live polls.',
                icon: Icons.person_outline,
                accentColor: AppTheme.primary,
                primaryButtonText: 'Voter Sign In',
                onPrimaryTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoterLoginScreen()),
                  );
                },
                secondaryButtonText: 'Register with Company ID',
                onSecondaryTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoterRegisterScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Option 2: Corporate Admin Portal
              _buildRoleCard(
                context,
                title: 'Organization Admin Portal',
                subtitle: 'Manage voters whitelist, configure elections (HR, CR, etc.), and monitor live tallies.',
                icon: Icons.admin_panel_settings_outlined,
                accentColor: AppTheme.accentIndigo,
                primaryButtonText: 'Admin Sign In',
                onPrimaryTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  );
                },
                secondaryButtonText: 'Setup New Organization Portal',
                onSecondaryTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminRegisterScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Multi-Tenant Isolated & Cryptographically Verified',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String primaryButtonText,
    required VoidCallback onPrimaryTap,
    required String secondaryButtonText,
    required VoidCallback onSecondaryTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onPrimaryTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                primaryButtonText,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onSecondaryTap,
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                secondaryButtonText,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
