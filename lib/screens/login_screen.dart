import 'dart:async';
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
  /// Called after a successful sign-in (returning user → go to home).
  final VoidCallback onSignIn;

  /// Called after a successful sign-up (new user → go to onboarding).
  final VoidCallback onSignUp;

  /// When true the screen opens in Create Account mode.
  final bool startInSignUpMode;

  const LoginScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
    this.startInSignUpMode = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late bool _isSignUp;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.startInSignUpMode;

    // Listen for OAuth sign-in completing in the browser and returning.
    _authSub = SupabaseService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn && mounted) {
        _onAuthSuccess();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onAuthSuccess() async {
    if (!mounted) return;
    final appState = context.read<AppState>();
    await appState.loadUserData();
    if (_isSignUp) {
      if (mounted) widget.onSignUp();
    } else {
      if (mounted) widget.onSignIn();
    }
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
      if (mounted) await _onAuthSuccess();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await SupabaseService.signInWithGoogle();
      // Navigation is handled by the auth state listener above.
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Could not open Google sign-in. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await SupabaseService.signInWithFacebook();
      // Navigation is handled by the auth state listener above.
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Could not open Facebook sign-in. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPassword() async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send Link', style: TextStyle(fontFamily: 'Inter', color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final email = emailController.text.trim();
      if (email.isEmpty) return;
      try {
        await SupabaseService.sendPasswordResetEmail(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send reset email. Please try again.')),
          );
        }
      }
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
                            onTap: _showForgotPassword,
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
                        label: _isSignUp ? 'Sign up with Google' : 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        iconColor: Colors.red,
                        onTap: _isLoading ? null : _signInWithGoogle,
                      ),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        label: _isSignUp ? 'Sign up with Facebook' : 'Continue with Facebook',
                        icon: Icons.facebook,
                        iconColor: Colors.blue,
                        onTap: _isLoading ? null : _signInWithFacebook,
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
              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textDisabled),
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
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(100),
          color: onTap == null ? AppColors.surface : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onTap == null ? AppColors.textDisabled : iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: onTap == null ? AppColors.textDisabled : AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
