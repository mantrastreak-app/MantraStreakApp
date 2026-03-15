import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'prayer_selection_screen.dart';

class PrayerPageScreen extends StatefulWidget {
  final Prayer prayer;
  final VoidCallback onClose;
  final VoidCallback onComplete;

  const PrayerPageScreen({
    super.key,
    required this.prayer,
    required this.onClose,
    required this.onComplete,
  });

  @override
  State<PrayerPageScreen> createState() => _PrayerPageScreenState();
}

class _PrayerPageScreenState extends State<PrayerPageScreen>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  int _elapsedSeconds = 0;
  bool _showCompletion = false;
  Timer? _timer;

  // Always 10 minutes
  static const int _totalSeconds = 600;

  int get _remaining => _totalSeconds - _elapsedSeconds;

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_elapsedSeconds < _totalSeconds) {
            _elapsedSeconds++;
          } else {
            _isPlaying = false;
            _timer?.cancel();
            _showCompletion = true;
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
              child: Stack(
                children: [
                  // ── Main content ──────────────────────────────────────────
                  Column(
                    children: [
                      _buildPrayerHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            children: [
                              _buildPrayerContent(),
                              const SizedBox(height: 16),
                              _buildBenefitsCard(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      _buildPlayerControls(),
                    ],
                  ),
                  // ── Streak complete overlay ───────────────────────────────
                  if (_showCompletion) _buildCompletionOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.prayer.title, style: AppTextStyles.titleLarge),
              Text(
                widget.prayer.deity.isEmpty ? 'Universal' : widget.prayer.deity,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: AppColors.textSubtle, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.streakCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SANSKRIT', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtle, letterSpacing: 0.35)),
          const SizedBox(height: 12),
          const Text(
            'ॐ। असतो मा सद्गमय। तमसो मा ज्योतिर्गमय। मृत्योर्मा अमृतं गमय। ॐ शान्तिः शान्तिः शान्तिः।',
            style: AppTextStyles.sanskritText,
          ),
          const SizedBox(height: 20),
          const Text('PRONUNCIATION', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtle, letterSpacing: 0.35)),
          const SizedBox(height: 12),
          const Text(
            'Om, Asato Ma Sad Gamaya, Tamaso Ma Jyotir Gamaya, Mrityor Ma Amritam Gamaya, Om Shanti Shanti Shanti',
            style: AppTextStyles.pronunciationText,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.primaryBorder),
          const SizedBox(height: 16),
          const Text('MEANING', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtle, letterSpacing: 0.35)),
          const SizedBox(height: 12),
          const Text(
            'Om, Lead me from untruth to truth. Lead me from darkness to light. Lead me from death to immortality. Om Peace, Peace, Peace.',
            style: AppTextStyles.quoteText,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BENEFITS', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtle, letterSpacing: 0.35)),
          const SizedBox(height: 8),
          Text(widget.prayer.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Big countdown display
          Text(
            _formatTime(_remaining),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isPlaying ? 'Chanting in progress…' : (_elapsedSeconds > 0 ? 'Paused' : '10 minute session'),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSubtle),
          ),
          const SizedBox(height: 20),
          // Large Start Chanting / Pause button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: _isPlaying ? null : AppGradients.primaryButton,
                color: _isPlaying ? AppColors.surface : null,
                borderRadius: BorderRadius.circular(100),
                border: _isPlaying ? Border.all(color: AppColors.border, width: 1.5) : null,
                boxShadow: _isPlaying ? null : [
                  const BoxShadow(color: Color(0x30FF6900), blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isPlaying ? AppColors.textMedium : AppColors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isPlaying ? 'Pause' : (_elapsedSeconds > 0 ? 'Resume Chanting' : 'Start Chanting'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _isPlaying ? AppColors.textMedium : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6900), Color(0xFFF54900)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 72),
              ),
              const SizedBox(height: 28),
              const Text('🔥', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Streak Complete!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your spiritual journey continues',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 52),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Awesome! 🙏',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
