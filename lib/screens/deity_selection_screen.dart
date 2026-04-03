import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class Deity {
  final String name;
  final IconData icon;
  final Color bgColor;

  const Deity({required this.name, required this.icon, required this.bgColor});
}

class DeitySelectionScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const DeitySelectionScreen({super.key, required this.onContinue});

  @override
  State<DeitySelectionScreen> createState() => _DeitySelectionScreenState();
}

class _DeitySelectionScreenState extends State<DeitySelectionScreen> {

  static const _deities = [
    Deity(name: 'Ganesha', icon: Icons.self_improvement, bgColor: AppColors.ganeshaIconBg),
    Deity(name: 'Shiva', icon: Icons.water_drop, bgColor: AppColors.shivaIconBg),
    Deity(name: 'Vishnu', icon: Icons.circle, bgColor: AppColors.vishnuIconBg),
    Deity(name: 'Lakshmi', icon: Icons.spa, bgColor: AppColors.lakshmiIconBg),
    Deity(name: 'Saraswati', icon: Icons.music_note, bgColor: AppColors.saraswatiIconBg),
    Deity(name: 'Hanuman', icon: Icons.fitness_center, bgColor: AppColors.hanumanIconBg),
    Deity(name: 'Durga', icon: Icons.shield, bgColor: AppColors.durgaIconBg),
    Deity(name: 'Krishna', icon: Icons.music_note_outlined, bgColor: AppColors.krishnaIconBg),
  ];

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
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Choose your deities', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 8),
                          const Text(
                            'Select the gods you wish to pray to daily',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          _buildDeityGrid(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: 'Continue',
                      onPressed: widget.onContinue,
                      showArrow: true,
                      isEnabled: context.watch<AppState>().selectedDeities.isNotEmpty,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: _buildProgressBar(0.25),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(100)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(color: AppColors.textDark, borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }

  Widget _buildDeityGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: _deities.length,
      itemBuilder: (context, index) {
        final deity = _deities[index];
        final isSelected = context.watch<AppState>().selectedDeities.contains(deity.name);
        return _DeityCard(
          deity: deity,
          isSelected: isSelected,
          onTap: () => context.read<AppState>().toggleDeity(deity.name),
        );
      },
    );
  }
}

class _DeityCard extends StatelessWidget {
  final Deity deity;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeityCard({required this.deity, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: deity.bgColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
                ],
              ),
              child: Icon(
                deity.icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textSubtle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              deity.name,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
