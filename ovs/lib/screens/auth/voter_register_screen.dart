import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/storage/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../voter/voter_dashboard_screen.dart';
import 'voter_login_screen.dart';

class VoterRegisterScreen extends StatefulWidget {
  const VoterRegisterScreen({super.key});

  @override
  State<VoterRegisterScreen> createState() => _VoterRegisterScreenState();
}

class _VoterRegisterScreenState extends State<VoterRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _orgCodeController;
  final _companyIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isVerified = false;
  String? _verifiedOrgName;
  String? _verificationError;

  @override
  void initState() {
    super.initState();
    _orgCodeController = TextEditingController(text: StorageService.getLastOrgCode() ?? '');
  }

  @override
  void dispose() {
    _orgCodeController.dispose();
    _companyIdController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCompanyId() async {
    final orgCode = _orgCodeController.text.trim();
    final companyId = _companyIdController.text.trim();

    if (orgCode.isEmpty || companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Organization Code and your Company ID first.')),
      );
      return;
    }

    setState(() {
      _verificationError = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.verifyVoterId(orgCode: orgCode, companyId: companyId);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _isVerified = true;
        _verifiedOrgName = result['organization']?['name'];
        final prefilled = result['prefilled'];
        if (prefilled != null) {
          if ((prefilled['name'] ?? '').isNotEmpty) {
            _nameController.text = prefilled['name'];
          }
          if ((prefilled['department'] ?? '').isNotEmpty) {
            _departmentController.text = prefilled['department'];
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'ID successfully verified!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      setState(() {
        _isVerified = false;
        _verificationError = result['message'] ?? 'Your ID is not authorized.';
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your company ID first.')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.registerVoter(
      orgCode: _orgCodeController.text.trim(),
      companyId: _companyIdController.text.trim(),
      name: _nameController.text.trim(),
      department: _departmentController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voter Registration Complete! Welcome.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VoterDashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
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
        title: const Text('Authorized Voter Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Secure Voter Onboarding',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Only employees pre-whitelisted by your company admin can register and vote.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),

                // Step 1: Verification Container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isVerified
                          ? AppTheme.success
                          : _verificationError != null
                              ? AppTheme.danger
                              : AppTheme.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isVerified ? Icons.check_circle : Icons.verified_user_outlined,
                            size: 18,
                            color: _isVerified ? AppTheme.success : AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isVerified ? 'STEP 1: ID VERIFIED' : 'STEP 1: VERIFY COMPANY ID',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isVerified ? AppTheme.success : AppTheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _orgCodeController,
                        label: 'Organization Code',
                        hint: 'e.g. DHAKA-CORP or JAMALPUR-01',
                        prefixIcon: Icons.apartment,
                        isUppercase: true,
                        readOnly: _isVerified,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter organization code' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _companyIdController,
                        label: 'Your Company / Employee ID',
                        hint: 'e.g. EMP-101 or CR-2026',
                        prefixIcon: Icons.badge_outlined,
                        isUppercase: true,
                        readOnly: _isVerified,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter your company ID' : null,
                      ),
                      const SizedBox(height: 14),

                      if (!_isVerified)
                        CustomButton(
                          text: 'Verify Authorized Status',
                          isLoading: auth.isLoading,
                          icon: Icons.search,
                          backgroundColor: AppTheme.accent,
                          onPressed: _verifyCompanyId,
                        ),

                      if (_isVerified)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Authorized by ${_verifiedOrgName ?? "Organization"}! Complete Step 2 below.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18, color: AppTheme.textMuted),
                                tooltip: 'Change ID',
                                onPressed: () {
                                  setState(() {
                                    _isVerified = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                      if (_verificationError != null && !_isVerified)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _verificationError!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Step 2: Account Details (enabled only when verified)
                AnimatedOpacity(
                  opacity: _isVerified ? 1.0 : 0.45,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_add_alt_1_outlined, size: 18, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'STEP 2: CREATE YOUR VOTER ACCOUNT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'e.g. Tanvir Ahmed',
                          prefixIcon: Icons.person_outline,
                          readOnly: !_isVerified,
                          validator: _isVerified
                              ? (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null
                              : null,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _departmentController,
                          label: 'Department / Class / Branch (Optional)',
                          hint: 'e.g. Human Resources or CSE Batch 22',
                          prefixIcon: Icons.work_outline,
                          readOnly: !_isVerified,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Create Secure Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: _obscurePassword,
                          readOnly: !_isVerified,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: _isVerified
                              ? (v) {
                                  if (v == null || v.isEmpty) return 'Enter a password';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                }
                              : null,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Complete Registration & Enter',
                          isLoading: auth.isLoading,
                          icon: Icons.how_to_reg,
                          onPressed: _isVerified ? _handleRegister : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const VoterLoginScreen()),
                          );
                        },
                        child: const Text(
                          'Sign In',
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
