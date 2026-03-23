import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  /// Called after the OTP is verified — should load user data and navigate to onboarding.
  final Future<void> Function() onVerified;

  /// Called when the user taps Back — return to sign-up.
  final VoidCallback onBack;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCooldown = 60;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _verify() async {
    final token = _otpController.text.trim();
    if (token.length != 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit code.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await SupabaseService.verifyEmailOtp(widget.email, token);
      await widget.onVerified();
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _isLoading) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await SupabaseService.resendEmailOtp(widget.email);
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code resent! Check your inbox.'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Could not resend code. Please try again.');
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: widget.onBack,
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: AppLogo(size: 64)),
                      const SizedBox(height: 20),
                      const Text(
                        'Verify your email',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit code sent to\n${widget.email}',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildOtpField(),
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
                            style: AppTextStyles.labelMedium
                                .copyWith(color: const Color(0xFFDC2626)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _isLoading ? 'Verifying…' : 'Verify Email',
                        onPressed: _isLoading ? null : _verify,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: (_resendCooldown > 0 || _isLoading) ? null : _resend,
                          child: Text(
                            _resendCooldown > 0
                                ? 'Resend code in ${_resendCooldown}s'
                                : 'Resend code',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _resendCooldown > 0
                                  ? AppColors.textDisabled
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ),
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

  Widget _buildOtpField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: 16,
        ),
        decoration: const InputDecoration(
          hintText: '· · · · · ·',
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            color: AppColors.textDisabled,
            letterSpacing: 8,
          ),
        ),
        onChanged: (value) {
          if (value.length == 6) _verify();
        },
      ),
    );
  }
}
