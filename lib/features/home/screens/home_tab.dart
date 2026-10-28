import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/recommendation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/page_scrubber.dart';
import '../../../core/widgets/recipe_image.dart';
import '../../minigames/screens/gacha_screen.dart';
import '../../minigames/screens/pour_over_screen.dart';
import '../../minigames/screens/tebak_kopi_screen.dart';
import '../models/recipe_model.dart';
import 'map_screen.dart';
import 'recipe_book_screen.dart';
import 'recipe_detail_screen.dart';
import 'timer_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({required this.onProfileTap, super.key});

  final VoidCallback onProfileTap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Recipe> _recommendations = const [];
  bool _isLoadingRecs = true;
  final _recommendationPageController = PageController(viewportFraction: 0.80);
  int _recommendationPage = 0;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _recommendationPageController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recs = await RecommendationService.instance
          .getSmartRecommendations();
      if (!mounted) return;
      setState(() {
        _recommendations = recs;
        _isLoadingRecs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRecs = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi';
    }
    if (hour < 15) {
      return 'Selamat Siang';
    }
    if (hour < 18) {
      return 'Selamat Sore';
    }
    return 'Selamat Malam';
  }

  String _userName() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadataName = user?.userMetadata?['full_name']?.toString().trim();
    if (metadataName != null && metadataName.isNotEmpty) {
      return metadataName.split(RegExp(r'\\s+')).first;
    }
    return 'Barista';
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      (
        icon: Icons.timer_outlined,
        title: 'Timer Seduh',
        subtitle: 'V60, Aeropress, dll',
        screen: const TimerScreen(),
        iconBackground: AppColors.lightCream,
      ),
      (
        icon: Icons.menu_book_outlined,
        title: 'Buku Resep',
        subtitle: '120+ Variasi',
        screen: const RecipeBookScreen(),
        iconBackground: AppColors.ivoryWhite,
      ),
      (
        icon: Icons.screen_rotation_outlined,
        title: 'Kocok Resep',
        subtitle: 'Gacha kopimu',
        screen: const GachaScreen(),
        iconBackground: AppColors.lightCream,
      ),
      (
        icon: Icons.help_outline,
        title: 'Kuis Kopi',
        subtitle: 'Uji pengetahuan kopimu',
        screen: const TebakKopiScreen(),
        iconBackground: AppColors.ivoryWhite,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header + Greeting ───
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
              decoration: const BoxDecoration(
                color: AppColors.darkCoffee,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()},',
                              style: const TextStyle(
                                color: AppColors.lightCream,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_userName()}!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.ivoryWhite,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onProfileTap,
                        tooltip: 'Buka profil',
                        icon: const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.lightCream,
                          child: Icon(
                            Icons.person,
                            color: AppColors.darkCoffee,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Rekomendasi Untukmu ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi Untukmu',
                    style: TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 1,
                    shadowColor: AppColors.darkCoffee.withValues(alpha: 0.08),
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(color: AppColors.lightCream),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 236,
                            child: _isLoadingRecs
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.mediumCoffee,
                                    ),
                                  )
                                : _recommendations.isEmpty
                                ? Center(
                                    child: Text(
                                      'Belum ada rekomendasi.',
                                      style: TextStyle(
                                        color: AppColors.mediumCoffee,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                : ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                        PointerDeviceKind.trackpad,
                                        PointerDeviceKind.stylus,
                                      },
                                    ),
                                    child: PageView.builder(
                                      controller:
                                          _recommendationPageController,
                                      physics:
                                          const BouncingScrollPhysics(),
                                      itemCount: _recommendations.length,
                                      onPageChanged: (index) => setState(
                                          () => _recommendationPage = index),
                                      itemBuilder: (context, index) {
                                        final recipe =
                                            _recommendations[index];
                                        return _RecommendationCard(
                                          recipe: recipe,
                                          onTap: () => _open(
                                            context,
                                            RecipeDetailScreen(
                                                recipe: recipe),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          if (!_isLoadingRecs && _recommendations.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: PageScrubber(
                                count: _recommendations.length,
                                currentPage: _recommendationPage,
                                color: AppColors.darkCoffee,
                                inactiveColor: AppColors.mediumCoffee,
                                height: 26,
                                onPageSelected: (index) {
                                  setState(() => _recommendationPage = index);
                                  _recommendationPageController.animateToPage(
                                    index,
                                    duration:
                                        const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Jelajahi Fitur ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jelajahi Fitur',
                    style: TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.map_outlined,
                    title: 'Peta Kedai Lokal',
                    subtitle: 'Temukan roastery di sekitarmu',
                    iconBackground: AppColors.lightCream,
                    wide: true,
                    onTap: () => _open(context, const MapScreen()),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    itemCount: menuItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.12,
                        ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return _MenuCard(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        iconBackground: item.iconBackground,
                        onTap: () => _open(context, item.screen),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.coffee_maker_outlined,
                    title: 'Pour-Over Challenge',
                    subtitle: 'Uji teknik seduhmu',
                    iconBackground: AppColors.ivoryWhite,
                    wide: true,
                    onTap: () => _open(context, const PourOverScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Recommendation Card ─────────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: AppColors.darkCoffee.withValues(alpha: 0.10),
        color: AppColors.darkCoffee,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppColors.mediumCoffee.withValues(alpha: 0.65),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeImage(
                  imageUrl: recipe.imageUrl,
                  width: double.infinity,
                  height: 115,
                  borderRadius: 13,
                  iconSize: 36,
                ),
                const SizedBox(height: 10),
                Text(
                  recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ivoryWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.lightCream,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.lightCream,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.duration} menit',
                      style: const TextStyle(
                        color: AppColors.lightCream,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Menu Card (unchanged) ───────────────────────

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconBackground,
    this.wide = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBackground;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final iconContainer = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: iconBackground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.mediumCoffee, size: 22),
    );

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shadowColor: AppColors.darkCoffee.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.lightCream),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: wide
              ? SizedBox(
                  height: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconContainer,
                      const SizedBox(width: 12),
                      Flexible(
                        child: _MenuCardText(title: title, subtitle: subtitle),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconContainer,
                    const SizedBox(height: 8),
                    _MenuCardText(title: title, subtitle: subtitle),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MenuCardText extends StatelessWidget {
  const _MenuCardText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.darkCoffee,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mediumCoffee, fontSize: 10),
        ),
      ],
    );
  }
}
