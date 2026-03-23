import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class MoodSelectorScreen extends StatefulWidget {
  final void Function(String mood) onContinue;
  final VoidCallback onBack;

  const MoodSelectorScreen({super.key, required this.onContinue, required this.onBack});

  @override
  State<MoodSelectorScreen> createState() => _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends State<MoodSelectorScreen> {
  String? _selectedMood;

  static const _moods = [
    _Mood(emoji: '😊', label: 'Awesome'),
    _Mood(emoji: '🙂', label: 'Good'),
    _Mood(emoji: '😐', label: 'Neutral'),
    _Mood(emoji: '😔', label: 'Bad'),
    _Mood(emoji: '😢', label: 'Terrible'),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
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
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'How are you feeling\ntoday?',
                            style: AppTextStyles.displayMedium.copyWith(height: 1.375),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose a mood to personalize your prayer',
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ..._moods.map((mood) => _MoodRow(
                            mood: mood,
                            isSelected: _selectedMood == mood.label,
                            onTap: () => setState(() => _selectedMood = mood.label),
                          )),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Continue',
                      onPressed: _selectedMood != null ? () => widget.onContinue(_selectedMood!) : null,
                      isEnabled: _selectedMood != null,
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

class _Mood {
  final String emoji;
  final String label;
  const _Mood({required this.emoji, required this.label});
}

class _MoodRow extends StatelessWidget {
  final _Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodRow({required this.mood, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 16),
                  Text(
                    mood.label,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
