import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  final int streak;
  final int totalDays;
  final VoidCallback onLetsPray;
  final VoidCallback onViewDashboard;
  final VoidCallback onProfile;
  final void Function(String mantraId) onFavouriteTap;

  const HomeScreen({
    super.key,
    this.streak = 0,
    this.totalDays = 0,
    required this.onLetsPray,
    required this.onViewDashboard,
    required this.onProfile,
    required this.onFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final favourites = context.watch<AppState>().favouriteMantraCards;

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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAppHeader(),
                            const SizedBox(height: 24),
                            _buildStreakCard(),
                            const SizedBox(height: 24),
                            if (favourites.isNotEmpty) ...[
                              _buildFavouritesSection(favourites),
                              const SizedBox(height: 24),
                            ],
                            _buildVerseCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GradientButton(
                      label: "Let's Pray",
                      onPressed: onLetsPray,
                      height: 68,
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

  Widget _buildAppHeader() {
    return Row(
      children: [
        const AppLogo(size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mantra Streak', style: AppTextStyles.headlineLarge.copyWith(fontSize: 24)),
              const Text('Continue your spiritual journey', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        GestureDetector(
          onTap: onProfile,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorderDark, width: 1.5),
            ),
            child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.streakCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                    child: const Icon(Icons.local_fire_department, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily Streak', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textLight)),
                      Text('$streak Days', style: AppTextStyles.streakNumber),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewDashboard,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBorderDark, width: 1),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 6 ? 8 : 0),
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: i < streak
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.textSubtle, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    streak == 0 ? 'Not completed yet' : '$streak day streak',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              Text('$totalDays total', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavouritesSection(List<Map<String, dynamic>> favourites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Favourite Mantras',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favourites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _FavouriteCard(
              data: favourites[i],
              onTap: () => onFavouriteTap(favourites[i]['id'] as String),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.streakCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verse of the Day', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text('Bhagavad Gita 2.20', style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '"The soul is neither born, and nor does it die. It is unborn, eternal, ever-existing and primeval."',
            style: AppTextStyles.quoteText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.primaryBorder),
          const SizedBox(height: 12),
          const Text(
            'न जायते म्रियते वा कदाचित्',
            style: TextStyle(
              fontFamily: 'Noto Sans Devanagari',
              fontSize: 14,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _FavouriteCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final todayCount = context.watch<AppState>().todayCountFor(
      data['id'] as String? ?? '',
    );
    final hasProgress = todayCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasProgress
            ? AppColors.primarySurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasProgress
              ? AppColors.primaryBorder
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                hasProgress
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppColors.primary,
                size: 13,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data['deity'] as String? ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            data['title'] as String? ?? '',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (hasProgress)
            Text(
              'Today: $todayCount chants ✓',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            )
          else
            Text(
              data['transliteration'] as String? ?? '',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSubtle,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      ),
    );
  }
}
