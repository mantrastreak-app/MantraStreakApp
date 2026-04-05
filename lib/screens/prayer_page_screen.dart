import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'prayer_selection_screen.dart';

enum _SessionMode { count, timer }

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
  // ── Mode ──────────────────────────────────────────────────────────────────
  _SessionMode _mode = _SessionMode.count;

  // ── Today's progress ──────────────────────────────────────────────────────
  int _todayCount = 0;
  int _todayTarget = 108;
  bool _progressLoaded = false;

  // ── Shared session state ──────────────────────────────────────────────────
  bool _sessionStarted = false;
  bool _isPlaying = false;
  bool _showCompletion = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // ── Count mode ────────────────────────────────────────────────────────────
  int _count = 0;
  int _target = 108;
  static const _presetTargets = [11, 21, 54, 108];

  // ── Timer mode ────────────────────────────────────────────────────────────
  int? _timerDurationSeconds;
  int get _timerRemaining {
    if (_timerDurationSeconds == null) return 0;
    final r = _timerDurationSeconds! - _elapsedSeconds;
    return r < 0 ? 0 : r;
  }
  static const _presetDurationMinutes = [5, 10, 15, 20, 30];

  // ── Audio ─────────────────────────────────────────────────────────────────
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
    _loadTodayProgress();
    final appState = context.read<AppState>();
    _target = appState.defaultCountTarget;
    _timerDurationSeconds = appState.defaultTimerMinutes * 60;
  }

  Future<void> _loadTodayProgress() async {
    final progress = await SupabaseService.loadTodayProgressForMantra(
      widget.prayer.id,
    );
    if (mounted) {
      setState(() {
        _todayCount = progress['count'] ?? 0;
        _todayTarget = progress['target'] ?? 108;
        _progressLoaded = true;
        // Resume from where user left off today
        if (_todayCount > 0) {
          _count = _todayCount;
          _target = _todayTarget;
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _audioPlayer?.dispose();
    super.dispose();
  }

  // ── Audio ─────────────────────────────────────────────────────────────────

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
          AudioSource.uri(Uri.parse(resolvedUrl), headers: headers));
      await player.setLoopMode(LoopMode.one);
      if (mounted) {
        setState(() {
          _audioReady = true;
          _audioLoading = false;
        });
        if (_isPlaying && !_isMuted) _audioPlayer?.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _audioError = 'Could not load audio';
          _audioLoading = false;
        });
      }
    }
  }

  void _playAudioIfNeeded() {
    if (_audioReady && _isPlaying && !_isMuted) _audioPlayer?.play();
  }

  void _pauseAudio() => _audioPlayer?.pause();

  void _toggleMute() {
    if (_audioPlayer == null || !_audioReady) return;
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) {
      _audioPlayer?.pause();
    } else if (_isPlaying) {
      _audioPlayer?.play();
    }
  }

  // ── Session ───────────────────────────────────────────────────────────────

  void _setMode(_SessionMode mode) {
    if (_sessionStarted) return;
    final appState = context.read<AppState>();
    setState(() {
      _mode = mode;
      _count = 0;
      _elapsedSeconds = 0;
      // Restore default timer instead of resetting to null
      _timerDurationSeconds = appState.defaultTimerMinutes * 60;
    });
  }

  void _startSession() {
    setState(() {
      _sessionStarted = true;
      _isPlaying = true;
    });
    _playAudioIfNeeded();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        if (_mode == _SessionMode.timer &&
            _timerDurationSeconds != null &&
            _elapsedSeconds >= _timerDurationSeconds!) {
          _completeSession();
        }
      });
    });
  }

  // Count: tap the big circle
  void _onCountTap() {
    if (_showCompletion) return;
    if (!_sessionStarted) _startSession();
    if (!_isPlaying) return;
    HapticFeedback.mediumImpact();
    setState(() => _count++);
    if (_count >= _target) _completeSession();
  }

  // Timer: start / pause / resume
  void _toggleTimerPlay() {
    if (_timerDurationSeconds == null) return;
    if (!_sessionStarted) {
      _startSession();
      return;
    }
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _playAudioIfNeeded();
      _startElapsedTimer();
    } else {
      _timer?.cancel();
      _pauseAudio();
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _audioPlayer?.stop();
    setState(() {
      _isPlaying = false;
      _sessionStarted = false;
      _showCompletion = true;
    });
    final appState = context.read<AppState>();
    if (_mode == _SessionMode.timer) {
      // Full timer completion — elapsed = full duration
      appState.pendingSessionCount = _elapsedSeconds;
      appState.pendingSessionTarget = 0; // 0 = fully completed
      appState.pendingSessionMode = 'timer';
    } else {
      appState.pendingSessionCount = _count;
      appState.pendingSessionTarget = _target;
      appState.pendingSessionMode = 'count';
    }
    _persistDuration();
  }

  void _persistDuration() {
    final secs = _elapsedSeconds > 0 ? _elapsedSeconds : 60;
    context.read<AppState>().selectedPrayerDuration = (secs / 60).ceil();
  }

  void _onClosePressed() {
    // If no session started, close immediately — no warning needed
    if (_elapsedSeconds == 0 && _count == 0) {
      widget.onClose();
      return;
    }

    // Session is in progress — pause and show options
    _timer?.cancel();
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      _pauseAudio();
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primaryBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.bookmark_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Save your progress?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle — shows what will be saved
            Text(
              _mode == _SessionMode.count
                  ? '$_count chants will be saved to your practice'
                  : '${_fmt(_elapsedSeconds)} of chanting will be saved',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSubtle,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Save & Exit button (primary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveAndExit();
                },
                child: const Text(
                  'Save & Exit',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Continue button (secondary)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMedium,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  side: const BorderSide(
                      color: AppColors.border, width: 1.5),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  // Resume the session
                  if (!_showCompletion) {
                    setState(() => _isPlaying = true);
                    _playAudioIfNeeded();
                    _startElapsedTimer();
                  }
                },
                child: const Text(
                  'Continue Chanting',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndExit() {
    _timer?.cancel();
    _pauseAudio();
    if (_elapsedSeconds > 0 || _count > 0) {
      _persistDuration();
      final appState = context.read<AppState>();
      if (_mode == _SessionMode.timer) {
        // For timer mode, use elapsed seconds as the
        // count so progress is stored and visible.
        // Target stays > 0 to signal partial (not complete).
        appState.pendingSessionCount = _elapsedSeconds;
        appState.pendingSessionTarget =
            _timerDurationSeconds ?? (_elapsedSeconds + 1);
        appState.pendingSessionMode = 'timer';
      } else {
        appState.pendingSessionCount = _count;
        appState.pendingSessionTarget = _target;
        appState.pendingSessionMode = 'count';
      }
      widget.onComplete();
    } else {
      widget.onClose();
    }
  }

  // ── Target bottom sheet ───────────────────────────────────────────────────

  void _showTargetSheet() {
    if (_sessionStarted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Set chanting target', style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text('How many times would you like to chant?',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSubtle)),
            const SizedBox(height: 20),
            _targetTile(ctx, 11, 'Quick session'),
            _targetTile(ctx, 21, 'Short practice'),
            _targetTile(ctx, 54, 'Half mala'),
            _targetTile(ctx, 108, 'Full mala'),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _showCustomTargetDialog();
              },
              child: _OptionTile(
                label: 'Custom',
                subtitle: 'Enter your own number',
                selected:
                    _target > 0 && !_presetTargets.contains(_target),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetTile(BuildContext ctx, int value, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _target = value;
          _count = 0;
        });
        Navigator.pop(ctx);
      },
      child: _OptionTile(
        label: '$value repetitions',
        subtitle: subtitle,
        selected: _target == value,
      ),
    );
  }

  void _showCustomTargetDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Custom target',
            style: TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'e.g. 40',
              border: OutlineInputBorder(),
              suffixText: 'times'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v > 0) {
                setState(() {
                  _target = v;
                  _count = 0;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showCustomDurationDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Custom duration',
            style: TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'e.g. 25',
              border: OutlineInputBorder(),
              suffixText: 'min'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v > 0) {
                setState(() => _timerDurationSeconds = v * 60);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildPrayerHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Unified content + controls card ──
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sanskrit section
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 20, 20, 0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _sectionLabel('SANSKRIT'),
                                    const SizedBox(height: 8),
                                    Text(widget.prayer.sanskritName,
                                        style:
                                            AppTextStyles.sanskritText),
                                    const SizedBox(height: 16),
                                    _sectionLabel('PRONUNCIATION'),
                                    const SizedBox(height: 8),
                                    Text(
                                        widget.prayer.transliteration,
                                        style: AppTextStyles
                                            .pronunciationText),
                                  ],
                                ),
                              ),

                              // Divider between content and controls
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                child: Container(
                                  height: 1,
                                  color: AppColors.border,
                                ),
                              ),

                              // Controls area inside the card
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 20),
                                child: Column(
                                  children: [
                                    if (widget.prayer.audioUrl != null &&
                                        widget.prayer.audioUrl!
                                            .isNotEmpty &&
                                        (_audioLoading ||
                                            _audioReady ||
                                            _audioError != null))
                                      _buildAudioBar(),
                                    if (_progressLoaded &&
                                        _todayCount > 0)
                                      _buildProgressBanner(),
                                    _buildModeToggle(),
                                    const SizedBox(height: 12),
                                    if (_mode == _SessionMode.count)
                                      _buildCountControls()
                                    else
                                      _buildTimerControls(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Meaning + Benefits below the main card
                        _buildMeaningCard(),
                        const SizedBox(height: 12),
                        _buildBenefitsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Save & Exit pinned at very bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: _buildSaveExitButton(),
            ),

            if (_showCompletion) _buildCompletionOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSubtle,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildProgressBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _todayCount >= _todayTarget
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _todayCount >= _todayTarget
                ? 'Completed today ✓'
                : 'Today so far: $_todayCount / $_todayTarget',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('MEANING'),
          const SizedBox(height: 8),
          Text(widget.prayer.meaning, style: AppTextStyles.quoteText),
        ],
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
                    widget.prayer.deity.isEmpty
                        ? 'Universal'
                        : widget.prayer.deity,
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
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
                color: isFav
                    ? AppColors.primarySurface
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: isFav
                    ? Border.all(
                        color: AppColors.primaryBorder, width: 1.5)
                    : null,
              ),
              child: Icon(
                isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color:
                    isFav ? AppColors.primary : AppColors.textSubtle,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _onClosePressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.close,
                  color: AppColors.textSubtle, size: 20),
            ),
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
          const Text('BENEFITS',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSubtle,
                  letterSpacing: 0.35)),
          const SizedBox(height: 8),
          Text(
            widget.prayer.objective.isNotEmpty
                ? widget.prayer.objective
                : widget.prayer.meaning,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }


  Widget _buildAudioBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note_rounded,
              size: 13, color: AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('MANTRA AUDIO',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSubtle,
                    letterSpacing: 0.5)),
          ),
          if (_audioLoading)
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary))
          else if (_audioError != null)
            const Icon(Icons.signal_wifi_off_rounded,
                size: 16, color: AppColors.textSubtle)
          else if (_audioReady)
            GestureDetector(
              onTap: _toggleMute,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _isMuted
                      ? AppColors.surface
                      : AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _isMuted
                          ? AppColors.border
                          : AppColors.primaryBorder,
                      width: 1.5),
                ),
                child: Icon(
                  _isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: _isMuted
                      ? AppColors.textSubtle
                      : AppColors.primary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _ModeTab(
            label: 'Count 📿',
            selected: _mode == _SessionMode.count,
            enabled: !_sessionStarted,
            onTap: () => _setMode(_SessionMode.count),
          ),
          _ModeTab(
            label: 'Timer ⏱',
            selected: _mode == _SessionMode.timer,
            enabled: !_sessionStarted,
            onTap: () => _setMode(_SessionMode.timer),
          ),
        ],
      ),
    );
  }

  // ── Count mode UI ─────────────────────────────────────────────────────────

  Widget _buildCountControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Elapsed time (subtle, top-left) + target pill (top-right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(_elapsedSeconds),
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textPale,
                  fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: _sessionStarted ? null : _showTargetSheet,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _sessionStarted
                      ? AppColors.surface
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: _sessionStarted
                          ? AppColors.border
                          : AppColors.primaryBorder,
                      width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded,
                        size: 12,
                        color: _sessionStarted
                            ? AppColors.textPale
                            : AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Target: $_target',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _sessionStarted
                              ? AppColors.textPale
                              : AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Big saffron tap circle
        GestureDetector(
          onTap: _onCountTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryButton,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x44FF6900),
                  blurRadius: _isPlaying ? 24 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_count',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        Text(
          '$_count / $_target',
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium),
        ),
        const SizedBox(height: 8),

        _buildBeadDots(),
      ],
    );
  }

  Widget _buildBeadDots() {
    // Cap at 108 for display; scale fill proportionally for larger targets
    final display = _target > 108 ? 108 : _target;
    final filled = _target > 108
        ? (_count / _target * 108).floor().clamp(0, 108)
        : _count.clamp(0, display);

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      children: [
        for (int i = 0; i < display; i++)
          Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(
              right: (i > 0 &&
                      (i + 1) % 27 == 0 &&
                      i < display - 1)
                  ? 9
                  : 2.5,
            ),
            decoration: BoxDecoration(
              color: i < filled
                  ? AppColors.primary
                  : AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  // ── Timer mode UI ─────────────────────────────────────────────────────────

  Widget _buildTimerControls() {
    // Once started (or paused mid-session), show countdown
    if (_sessionStarted ||
        (_timerDurationSeconds != null && _elapsedSeconds > 0)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _fmt(_timerRemaining),
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(
            _isPlaying
                ? 'Chanting in progress…'
                : (_elapsedSeconds > 0 ? 'Paused' : 'Ready'),
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSubtle),
          ),
          const SizedBox(height: 10),
          _buildTimerPlayButton(),
        ],
      );
    }

    // Pre-start: duration selector
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose duration',
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textMedium)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._presetDurationMinutes.map((m) => _DurationChip(
                  label: '$m min',
                  selected: _timerDurationSeconds == m * 60,
                  onTap: () =>
                      setState(() => _timerDurationSeconds = m * 60),
                )),
            _DurationChip(
              label: 'Custom',
              selected: _timerDurationSeconds != null &&
                  !_presetDurationMinutes
                      .contains(_timerDurationSeconds! ~/ 60),
              onTap: _showCustomDurationDialog,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTimerPlayButton(),
      ],
    );
  }

  Widget _buildTimerPlayButton() {
    final ready = _timerDurationSeconds != null || _sessionStarted;
    return GestureDetector(
      onTap: ready ? _toggleTimerPlay : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: ready && !_isPlaying
              ? AppGradients.primaryButton
              : null,
          color: !ready
              ? AppColors.surface
              : (_isPlaying ? AppColors.surface : null),
          borderRadius: BorderRadius.circular(100),
          border: (!ready || _isPlaying)
              ? Border.all(
                  color:
                      ready ? AppColors.border : AppColors.borderDark,
                  width: 1.5)
              : null,
          boxShadow: ready && !_isPlaying
              ? [
                  const BoxShadow(
                      color: Color(0x30FF6900),
                      blurRadius: 16,
                      offset: Offset(0, 6))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: !ready
                  ? AppColors.textPale
                  : (_isPlaying
                      ? AppColors.textMedium
                      : AppColors.white),
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              _isPlaying
                  ? 'Pause'
                  : (_elapsedSeconds > 0
                      ? 'Resume Chanting'
                      : 'Start Chanting'),
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: !ready
                      ? AppColors.textPale
                      : (_isPlaying
                          ? AppColors.textMedium
                          : AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveExitButton() {
    return GestureDetector(
      onTap: _saveAndExit,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_alt_rounded,
                size: 14, color: AppColors.textMedium),
            SizedBox(width: 7),
            Text('Save & Exit',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }

  // ── Completion overlay ────────────────────────────────────────────────────

  Widget _buildCompletionOverlay() {
    final isCount = _mode == _SessionMode.count;
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
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
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 72),
              ),
              const SizedBox(height: 24),
              const Text('🔥',
                  style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              const Text('Streak Complete!',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                isCount
                    ? '$_count mantras · ${_fmt(_elapsedSeconds)}'
                    : _fmt(_elapsedSeconds),
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 6),
              Text(
                'Your spiritual journey continues',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onComplete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: const Text('Awesome! 🙏',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    const BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, 1))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.textDark
                    : (enabled
                        ? AppColors.textSubtle
                        : AppColors.textPale),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySurface
              : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.primary
                  : AppColors.textMedium),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;

  const _OptionTile(
      {required this.label,
      required this.subtitle,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primarySurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSubtle)),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
