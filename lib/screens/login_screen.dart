import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSkip;

  const LoginScreen({
    super.key,
    required this.onSignIn,
    required this.onSkip,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await SupabaseService.signUpWithEmail(email, password);
      } else {
        await SupabaseService.signInWithEmail(email, password);
      }
      if (mounted) {
        // Load user data from Supabase then navigate
        await context.read<AppState>().loadUserData();
        // Save onboarding settings for newly registered users
        if (_isSignUp) {
          await context.read<AppState>().saveProfile();
        }
        widget.onSignIn();
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 50, offset: Offset(0, 25)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: widget.onSkip,
                          child: Text(
                            'Skip for now',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textLight),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(child: AppLogo(size: 64)),
                      const SizedBox(height: 20),
                      Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignUp
                            ? 'Start your spiritual journey today'
                            : 'Sign in to continue your spiritual journey',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildLabel('Email'),
                      const SizedBox(height: 6),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      _buildPasswordField(),
                      if (!_isSignUp) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Forgot password?',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      const SizedBox(height: 24),
                      GradientButton(
                        label: _isLoading
                            ? (_isSignUp ? 'Creating account…' : 'Signing in…')
                            : (_isSignUp ? 'Create Account' : 'Sign In'),
                        onPressed: _isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or', style: AppTextStyles.bodyMedium),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSocialButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        iconColor: Colors.red,
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        label: 'Continue with Facebook',
                        icon: Icons.facebook,
                        iconColor: Colors.blue,
                        onTap: () {},
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            }),
                            child: Text(
                              _isSignUp ? 'Sign In' : 'Sign Up',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMedium),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.email_outlined, color: AppColors.textDisabled, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
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
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: '••••••••',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textDisabled,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}
