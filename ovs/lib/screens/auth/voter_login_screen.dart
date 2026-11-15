import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/storage/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../voter/voter_dashboard_screen.dart';
import 'voter_register_screen.dart';

class VoterLoginScreen extends StatefulWidget {
  const VoterLoginScreen({super.key});

  @override
  State<VoterLoginScreen> createState() => _VoterLoginScreenState();
}

class _VoterLoginScreenState extends State<VoterLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _orgCodeController;
  final _companyIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _orgCodeController = TextEditingController(text: StorageService.getLastOrgCode() ?? '');
  }

  @override
  void dispose() {
    _orgCodeController.dispose();
    _companyIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.loginVoter(
      orgCode: _orgCodeController.text.trim(),
      companyId: _companyIdController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VoterDashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Voter login failed'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Portal Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Welcome Voter',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your company credentials to view ballots and cast your vote.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 30),

                // Organization Code
                CustomTextField(
                  controller: _orgCodeController,
                  label: 'Organization Code',
                  hint: 'e.g. DHAKA-CORP or JAMALPUR-01',
                  prefixIcon: Icons.apartment,
                  isUppercase: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Enter organization code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Company / Employee ID
                CustomTextField(
                  controller: _companyIdController,
                  label: 'Your Company / Employee ID',
                  hint: 'e.g. EMP-101 or CR-2026',
                  prefixIcon: Icons.badge_outlined,
                  isUppercase: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Enter your company ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'Sign In & View Ballots',
                  isLoading: auth.isLoading,
                  icon: Icons.login,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'First time here?',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const VoterRegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register with Company ID',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
