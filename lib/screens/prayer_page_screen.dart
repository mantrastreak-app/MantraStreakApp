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

class _PrayerPageScreenState extends State<PrayerPageScreen> {
  bool _isPlaying = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  int get _totalSeconds => widget.prayer.durationMinutes * 60;
  double get _progress => _elapsedSeconds / _totalSeconds;

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
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
            widget.onComplete();
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
    final remaining = _totalSeconds - _elapsedSeconds;
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
                  _buildTopBar(),
                  _buildPrayerHeader(),
                  _buildProgressBar(),
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
                  _buildPlayerControls(remaining),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('4:09', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMedium)),
          Icon(Icons.battery_full, color: AppColors.textMedium, size: 18),
        ],
      ),
    );
  }

  Widget _buildPrayerHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.prayer.title, style: AppTextStyles.titleLarge),
              Text(widget.prayer.deity.isEmpty ? 'Universal' : widget.prayer.deity,
                  style: AppTextStyles.bodyMedium),
            ],
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.textSubtle, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(_elapsedSeconds), style: AppTextStyles.labelSmall),
              Text('-${_formatTime(_totalSeconds - _elapsedSeconds)}', style: AppTextStyles.labelSmall),
            ],
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
          // Sanskrit section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SANSKRIT',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSubtle,
                  letterSpacing: 0.35,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_outlined, color: AppColors.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'ॐ। असतो मा सद्गमय। तमसो मा ज्योतिर्गमय। मृत्योर्मा अमृतं गमय। ॐ शान्तिः शान्तिः शान्तिः।',
            style: AppTextStyles.sanskritText,
          ),
          const SizedBox(height: 20),
          // Pronunciation section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRONUNCIATION',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSubtle,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Om, Asato Ma Sad Gamaya, Tamaso Ma Jyotir Gamaya, Mrityor Ma Amritam Gamaya, Om Shanti Shanti Shanti',
                style: AppTextStyles.pronunciationText,
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.primaryBorder.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 16),
          // Meaning section
          const Text(
            'MEANING',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtle,
              letterSpacing: 0.35,
            ),
          ),
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
          const Text(
            'BENEFITS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtle,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.prayer.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(int remaining) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 25, offset: Offset(0, 20)),
                  BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 8)),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.prayer.description, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
