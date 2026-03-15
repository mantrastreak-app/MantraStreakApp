import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class Prayer {
  final String title;
  final String sanskritName;
  final String transliteration;
  final String description;
  final int durationMinutes;
  final String deity;
  final Color iconBg;
  final IconData icon;

  const Prayer({
    required this.title,
    required this.sanskritName,
    required this.transliteration,
    required this.description,
    required this.durationMinutes,
    required this.deity,
    required this.iconBg,
    required this.icon,
  });
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

  static final List<Prayer> _prayers = [
    const Prayer(
      title: 'Healing Prayer',
      sanskritName: 'महामृत्युंजय मंत्र',
      transliteration: 'Mahamrityunjaya Mantra',
      description: 'Powerful healing and rejuvenation',
      durationMinutes: 10,
      deity: 'Shiva',
      iconBg: Color(0x21E8E8E8),
      icon: Icons.favorite_border,
    ),
    const Prayer(
      title: 'Strength Mantra',
      sanskritName: 'ॐ हनुमते नमः',
      transliteration: 'Salutations to Hanuman',
      description: 'Builds inner strength and courage',
      durationMinutes: 8,
      deity: 'Hanuman',
      iconBg: Color(0x21FF6347),
      icon: Icons.fitness_center,
    ),
    const Prayer(
      title: 'Comfort Chant',
      sanskritName: 'सांत्वना मंत्र',
      transliteration: 'Prayer for solace',
      description: 'Soothes emotional pain',
      durationMinutes: 7,
      deity: '',
      iconBg: Color(0x21DDA0DD),
      icon: Icons.nightlight_round,
    ),
    const Prayer(
      title: 'Release Prayer',
      sanskritName: 'मुक्ति मंत्र',
      transliteration: 'Mantra for letting go',
      description: 'Releases negative emotions',
      durationMinutes: 9,
      deity: '',
      iconBg: Color(0x21FFB6C1),
      icon: Icons.spa,
    ),
  ];

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
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: widget.onBack,
                            child: Text(
                              '← Back',
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSubtle),
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
              // Icon
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
                    Text(prayer.description, style: AppTextStyles.labelSmall),
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
