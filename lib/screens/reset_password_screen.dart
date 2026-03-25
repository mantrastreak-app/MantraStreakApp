import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';
import '../services/supabase_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final VoidCallback onPasswordReset;

  const ResetPasswordScreen({super.key, required this.onPasswordReset});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();

    if (newPw.isEmpty || confirmPw.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields.');
      return;
    }
    if (newPw.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (newPw != confirmPw) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await SupabaseService.updatePassword(newPw);
      if (mounted) setState(() { _success = true; _isLoading = false; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onPasswordReset();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update password. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            color: AppColors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            const Center(child: AppLogo(size: 64)),
                            const SizedBox(height: 20),
                            const Text(
                              'Set New Password',
                              style: AppTextStyles.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Choose a strong password for your account',
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 36),
                            if (_success) ...[
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Password updated successfully! Redirecting…',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          color: Color(0xFF15803D),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              _buildLabel('New Password'),
                              const SizedBox(height: 6),
                              _buildPasswordField(_newPasswordController, _obscureNew, (v) => setState(() => _obscureNew = v)),
                              const SizedBox(height: 16),
                              _buildLabel('Confirm New Password'),
                              const SizedBox(height: 6),
                              _buildPasswordField(_confirmPasswordController, _obscureConfirm, (v) => setState(() => _obscureConfirm = v)),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFFDC2626)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              GradientButton(
                                label: _isLoading ? 'Updating…' : 'Update Password',
                                onPressed: _isLoading ? null : _submit,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMedium));
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    bool obscure,
    void Function(bool) onToggle,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.lock_outline, color: AppColors.textDisabled, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText: '••••••••',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textDisabled),
              ),
            ),
          ),
          IconButton(
            onPressed: () => onToggle(!obscure),
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textDisabled,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
