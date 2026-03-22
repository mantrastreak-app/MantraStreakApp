import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
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
  // ── Session timer ─────────────────────────────────────────────────────────
  bool _isPlaying = false;
  int _elapsedSeconds = 0;
  bool _showCompletion = false;
  Timer? _timer;
  static const int _totalSeconds = 600;
  int get _remaining => _totalSeconds - _elapsedSeconds;

  // ── Audio player ──────────────────────────────────────────────────────────
  AudioPlayer? _audioPlayer;
  bool _audioReady = false;
  bool _audioPlaying = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _audioLoading = false;
  String? _audioError;
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final url = widget.prayer.audioUrl;
    if (url == null || url.isEmpty) return;

    setState(() => _audioLoading = true);
    final player = AudioPlayer();
    _audioPlayer = player;

    _subs.add(player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlaying = state.playing);
    }));

    _subs.add(player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _audioPosition = pos);
    }));

    _subs.add(player.durationStream.listen((dur) {
      if (!mounted) return;
      setState(() => _audioDuration = dur ?? Duration.zero);
    }));

    try {
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.one);
      if (mounted) setState(() { _audioReady = true; _audioLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _audioError = 'Could not load audio'; _audioLoading = false; });
    }
  }

  void _toggleAudio() {
    final player = _audioPlayer;
    if (player == null || !_audioReady) return;
    if (_audioPlaying) {
      player.pause();
    } else {
      player.play();
    }
  }

  void _seekAudio(double value) {
    final player = _audioPlayer;
    if (player == null || !_audioReady || _audioDuration == Duration.zero) return;
    player.seek(Duration(milliseconds: (value * _audioDuration.inMilliseconds).round()));
  }

  // ── Session timer ─────────────────────────────────────────────────────────
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
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
            _audioPlayer?.stop();
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
    for (final s in _subs) { s.cancel(); }
    _audioPlayer?.dispose();
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
          Text(widget.prayer.sanskritName, style: AppTextStyles.sanskritText),
          const SizedBox(height: 20),
          const Text('PRONUNCIATION', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtle, letterSpacing: 0.35)),
          const SizedBox(height: 12),
          Text(widget.prayer.transliteration, style: AppTextStyles.pronunciationText),
          const SizedBox(height: 16),
          const Divider(color: AppColors.primaryBorder),
          const SizedBox(height: 16),
          const Text('MEANING', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtle, letterSpacing: 0.35)),
          const SizedBox(height: 12),
          Text(widget.prayer.meaning, style: AppTextStyles.quoteText),
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
          Text(
            widget.prayer.objective.isNotEmpty ? widget.prayer.objective : widget.prayer.meaning,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium),
          ),
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
          // ── Audio player (shown only when audio URL exists) ────────────
          if (widget.prayer.audioUrl != null && widget.prayer.audioUrl!.isNotEmpty)
            _buildAudioSection(),

          // ── Session timer ─────────────────────────────────────────────
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
          // ── Start / Pause chanting button ─────────────────────────────
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

  Widget _buildAudioSection() {
    final sliderValue = (_audioDuration.inMilliseconds > 0)
        ? (_audioPosition.inMilliseconds / _audioDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'MANTRA AUDIO',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSubtle,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (_audioLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else if (_audioError != null)
                const Icon(Icons.error_outline, size: 18, color: AppColors.textLight)
              else
                GestureDetector(
                  onTap: _toggleAudio,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _audioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          if (_audioError != null) ...[
            const SizedBox(height: 6),
            Text(_audioError!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textLight)),
          ] else if (_audioReady) ...[
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primarySurface,
              ),
              child: Slider(
                value: sliderValue,
                onChanged: _seekAudio,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_audioPosition), style: AppTextStyles.labelSmall),
                  Text(_formatDuration(_audioDuration), style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          ],
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
