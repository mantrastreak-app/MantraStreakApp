import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../services/supabase_service.dart';
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
  bool _audioLoading = false;
  bool _isMuted = false;
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

    try {
      final resolvedUrl = await SupabaseService.resolveAudioUrl(url);

      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      await player.setAudioSource(
        AudioSource.uri(Uri.parse(resolvedUrl), headers: headers),
      );
      await player.setLoopMode(LoopMode.one);
      if (mounted) setState(() { _audioReady = true; _audioLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _audioError = 'Could not load audio';
          _audioLoading = false;
        });
      }
    }
  }

  // ── Mute / unmute (audio playback is controlled by chanting session) ───────
  Future<void> _toggleMute() async {
    final player = _audioPlayer;
    if (player == null || !_audioReady) return;
    // Compute the new state before calling setState so the volume call
    // always uses the correct (intended) value.
    final newMuted = !_isMuted;
    setState(() => _isMuted = newMuted);
    await player.setVolume(newMuted ? 0.0 : 1.0);
  }

  // ── Session timer + audio sync ─────────────────────────────────────────────
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      // Start audio when chanting starts
      if (_audioReady) {
        _audioPlayer?.setVolume(_isMuted ? 0.0 : 1.0);
        _audioPlayer?.play();
      }
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
      // Pause audio when chanting is paused
      _timer?.cancel();
      _audioPlayer?.pause();
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
            color: AppColors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
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
    final appState = context.watch<AppState>();
    final isFav = appState.isFavourite(widget.prayer.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.prayer.title, style: AppTextStyles.titleLarge),
                Text(
                  widget.prayer.deity.isEmpty ? 'Universal' : widget.prayer.deity,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          // Favourite toggle
          GestureDetector(
            onTap: () => appState.toggleFavourite(
              id: widget.prayer.id,
              title: widget.prayer.title,
              deity: widget.prayer.deity,
              transliteration: widget.prayer.transliteration,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isFav ? AppColors.primarySurface : AppColors.surface,
                shape: BoxShape.circle,
                border: isFav ? Border.all(color: AppColors.primaryBorder, width: 1.5) : null,
              ),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? AppColors.primary : AppColors.textSubtle,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Close
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
          // ── Audio mute bar (shown when audio is available) ─────────────
          if ((widget.prayer.audioUrl != null && widget.prayer.audioUrl!.isNotEmpty) &&
              (_audioLoading || _audioReady || _audioError != null))
            _buildAudioBar(),

          // ── Session timer ──────────────────────────────────────────────
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
          // ── Start / Pause chanting button ──────────────────────────────
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

  Widget _buildAudioBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'MANTRA AUDIO',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSubtle,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (_audioLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          else if (_audioError != null)
            const Icon(Icons.signal_wifi_off_rounded, size: 18, color: AppColors.textSubtle)
          else if (_audioReady)
            GestureDetector(
              onTap: _toggleMute,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isMuted ? AppColors.surface : AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isMuted ? AppColors.border : AppColors.primaryBorder,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _isMuted ? AppColors.textSubtle : AppColors.primary,
                  size: 18,
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
