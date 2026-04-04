import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'mood_selector_screen.dart';
import 'prayer_selection_screen.dart';
import 'prayer_page_screen.dart';
import 'monthly_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final int streak;
  final int totalDays;
  final VoidCallback onViewDashboard;
  final VoidCallback onProfile;
  final void Function(String mantraId) onFavouriteTap;
  final String? initialMood;

  const HomeScreen({
    super.key,
    this.streak = 0,
    this.totalDays = 0,
    required this.onViewDashboard,
    required this.onProfile,
    required this.onFavouriteTap,
    this.initialMood,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildChantTab(),
          _buildProgressTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSubtle,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: 'Chant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final favourites = context.watch<AppState>().favouriteMantraCards;
    return SafeArea(
      child: Container(
        color: AppColors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppHeader(),
              const SizedBox(height: 24),
              _buildStreakCard(),
              const SizedBox(height: 20),
              _buildChantCTA(),
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
    );
  }

  Widget _buildChantTab() {
    return MoodSelectorScreen(
      onBack: () => setState(() => _selectedIndex = 0),
      onContinue: (mood) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PrayerSelectionScreen(
              mood: mood,
              onStart: (prayer) {
                final appState = context.read<AppState>();
                appState.selectedPrayer = prayer.title;
                appState.selectedPrayerDeity = prayer.deity;
                appState.selectedPrayerMantraId = prayer.id;
                appState.selectedPrayerDuration = prayer.durationMinutes;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrayerPageScreen(
                      prayer: prayer,
                      onClose: () => Navigator.of(context).pop(),
                      onComplete: () {
                        appState.completePrayer();
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      },
                    ),
                  ),
                );
              },
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    final appState = context.watch<AppState>();
    return MonthlyDashboardScreen(
      dayStreak: appState.prayerStreak,
      bestStreak: appState.bestStreak,
      totalDays: appState.totalPrayerDays,
      completedDays: appState.completedDays,
      onClose: () => setState(() => _selectedIndex = 0),
    );
  }

  Widget _buildChantCTA() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40FF6900),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Chanting',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap to choose your mantra',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
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
          onTap: widget.onProfile,
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
                      Text('${widget.streak} Days', style: AppTextStyles.streakNumber),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onViewDashboard,
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
                    color: i < widget.streak
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
                    widget.streak == 0 ? 'Not completed yet' : '${widget.streak} day streak',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              Text('${widget.totalDays} total', style: AppTextStyles.labelSmall),
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
              onTap: () => widget.onFavouriteTap(favourites[i]['id'] as String),
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
