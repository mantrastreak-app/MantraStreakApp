import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      // Skip for now
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
                      // Logo + Title
                      Center(child: const AppLogo(size: 64)),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your spiritual journey',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Email field
                      _buildLabel('Email'),
                      const SizedBox(height: 6),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      // Password field
                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      // Forgot password
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
                      const SizedBox(height: 24),
                      // Sign In button
                      GradientButton(label: 'Sign In', onPressed: widget.onSignIn),
                      const SizedBox(height: 24),
                      // Divider
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
                      // Social buttons
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
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Sign Up',
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
