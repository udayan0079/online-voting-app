import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../admin/admin_dashboard_screen.dart';
import 'admin_login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _orgNameController = TextEditingController();
  final _orgCodeController = TextEditingController();
  final _addressController = TextEditingController();

  final _adminNameController = TextEditingController();
  final _adminIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgCodeController.dispose();
    _addressController.dispose();
    _adminNameController.dispose();
    _adminIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.registerAdmin(
      orgName: _orgNameController.text.trim(),
      orgCode: _orgCodeController.text.trim(),
      address: _addressController.text.trim(),
      adminName: _adminNameController.text.trim(),
      adminCompanyId: _adminIdController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organization Portal successfully launched!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
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
        title: const Text('Setup Organization Portal'),
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
                  'Launch Company Voting Space',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your organization will have its own private, isolated database partition.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),

                // Section 1: Company Profile
                const Row(
                  children: [
                    Icon(Icons.apartment, size: 18, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'COMPANY DETAILS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                CustomTextField(
                  controller: _orgNameController,
                  label: 'Company / Organization Name',
                  hint: 'e.g. Acme Tech Ltd or Jamalpur University',
                  prefixIcon: Icons.corporate_fare,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter company name' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _orgCodeController,
                  label: 'Unique Portal Code (ID)',
                  hint: 'e.g. ACME-TECH or JAMALPUR-01',
                  prefixIcon: Icons.key,
                  isUppercase: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter a unique code';
                    if (v.trim().length < 3) return 'At least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _addressController,
                  label: 'Office Location / Branch (Optional)',
                  hint: 'e.g. Dhaka or Jamalpur, Bangladesh',
                  prefixIcon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 28),

                // Section 2: Admin Profile
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'ROOT ADMINISTRATOR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                CustomTextField(
                  controller: _adminNameController,
                  label: 'Admin Full Name',
                  hint: 'e.g. Md. Rahim Admin',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter admin name' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _adminIdController,
                  label: 'Admin Company ID',
                  hint: 'e.g. ADM-001 or EMP-001',
                  prefixIcon: Icons.badge_outlined,
                  isUppercase: true,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter employee ID' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailController,
                  label: 'Official Email (Optional)',
                  hint: 'admin@company.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Admin Portal Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                CustomButton(
                  text: 'Create Organization & Launch Portal',
                  isLoading: auth.isLoading,
                  icon: Icons.check_circle_outline,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an organization?',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
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
