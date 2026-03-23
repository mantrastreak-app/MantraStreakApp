import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../services/supabase_service.dart';

class Prayer {
  final String id;
  final String title;
  final String sanskritName;
  final String transliteration;
  final String meaning;
  final String moodSpecificMeaning;
  final String objective;
  final String deity;
  final int durationSeconds;
  final String? audioUrl;
  final Color iconBg;
  final IconData icon;

  const Prayer({
    required this.id,
    required this.title,
    required this.sanskritName,
    required this.transliteration,
    required this.meaning,
    required this.moodSpecificMeaning,
    required this.objective,
    required this.deity,
    required this.durationSeconds,
    this.audioUrl,
    required this.iconBg,
    required this.icon,
  });

  int get durationMinutes => (durationSeconds / 60).ceil().clamp(1, 60);

  factory Prayer.fromSupabase(Map<String, dynamic> row) {
    return Prayer(
      id: (row['mantra_id'] ?? '').toString(),
      title: row['title'] as String? ?? '',
      sanskritName: row['sanskrit_name'] as String? ?? '',
      transliteration: row['transliteration'] as String? ?? '',
      meaning: row['meaning'] as String? ?? '',
      moodSpecificMeaning: row['mood_specific_meaning'] as String? ?? '',
      objective: row['objective'] as String? ?? '',
      deity: row['deity'] as String? ?? '',
      durationSeconds: row['duration_seconds'] as int? ?? 0,
      audioUrl: row['audio_url'] as String?,
      iconBg: _parseColor(row['icon_color_hex'] as String?),
      icon: _parseIcon(row['icon_name'] as String?),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.length < 7) return const Color(0x21E8E8E8);
    try {
      final value = int.parse(hex.replaceAll('#', ''), radix: 16);
      return Color(0xFF000000 | value).withValues(alpha: 0.15);
    } catch (_) {
      return const Color(0x21E8E8E8);
    }
  }

  static IconData _parseIcon(String? name) {
    const map = <String, IconData>{
      'wb_sunny': Icons.wb_sunny,
      'music_note': Icons.music_note,
      'celebration': Icons.celebration,
      'favorite': Icons.favorite,
      'self_improvement': Icons.self_improvement,
      'auto_awesome': Icons.auto_awesome,
      'light_mode': Icons.light_mode,
      'shield': Icons.shield,
      'emoji_events': Icons.emoji_events,
      'fitness_center': Icons.fitness_center,
      'whatshot': Icons.whatshot,
      'spa': Icons.spa,
      'volunteer_activism': Icons.volunteer_activism,
      'star': Icons.star,
      'all_inclusive': Icons.all_inclusive,
      'healing': Icons.healing,
      'nightlight_round': Icons.nightlight_round,
      'monetization_on': Icons.monetization_on,
      'diamond': Icons.diamond,
      'verified': Icons.verified,
      'psychology': Icons.psychology,
      'favorite_border': Icons.favorite_border,
      'air': Icons.air,
      'shield_outlined': Icons.shield_outlined,
    };
    return map[name] ?? Icons.self_improvement;
  }
}

class PrayerSelectionScreen extends StatefulWidget {
  final String mood;
  final void Function(Prayer prayer) onStart;
  final VoidCallback onBack;

  const PrayerSelectionScreen({
    super.key,
    required this.mood,
    required this.onStart,
    required this.onBack,
  });

  @override
  State<PrayerSelectionScreen> createState() => _PrayerSelectionScreenState();
}

class _PrayerSelectionScreenState extends State<PrayerSelectionScreen> {
  Prayer? _selectedPrayer;
  List<Prayer> _prayers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await SupabaseService.fetchMantrasByMood(widget.mood);
      setState(() {
        _prayers = rows.map(Prayer.fromSupabase).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: widget.onBack,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textSubtle),
                                const SizedBox(width: 4),
                                Text('Back', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSubtle)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "We're here to support you",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose a prayer or mantra that resonates with you',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          if (_loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_error != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text('Failed to load mantras.\n$_error',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSubtle)),
                              ),
                            )
                          else
                            ..._prayers.map((p) => _PrayerCard(
                              prayer: p,
                              isSelected: _selectedPrayer == p,
                              onTap: () => setState(() => _selectedPrayer = p),
                            )),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Start Prayer',
                      onPressed: _selectedPrayer != null
                          ? () => widget.onStart(_selectedPrayer!)
                          : null,
                      isEnabled: _selectedPrayer != null,
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
}

class _PrayerCard extends StatelessWidget {
  final Prayer prayer;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrayerCard({required this.prayer, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: prayer.iconBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
                  ],
                ),
                child: Icon(prayer.icon, size: 24, color: AppColors.textSubtle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayer.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      prayer.sanskritName,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans Devanagari',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSubtle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prayer.transliteration,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (prayer.deity.isNotEmpty)
                      _Tag(text: prayer.deity, dotColor: const Color(0xFF51A2FF)),
                    const SizedBox(height: 8),
                    Text(prayer.moodSpecificMeaning.isNotEmpty
                        ? prayer.moodSpecificMeaning
                        : prayer.meaning,
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color dotColor;

  const _Tag({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
