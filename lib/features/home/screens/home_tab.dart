import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../minigames/screens/gacha_screen.dart';
import '../../minigames/screens/pour_over_screen.dart';
import '../../minigames/screens/tebak_kopi_screen.dart';
import '../models/recipe_catalog.dart';
import 'map_screen.dart';
import 'recipe_book_screen.dart';
import 'recipe_detail_screen.dart';
import 'timer_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({required this.onProfileTap, super.key});

  final VoidCallback onProfileTap;

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
      return metadataName.split(RegExp(r'\s+')).first;
    }
    return 'Barista';
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final recommendedRecipe = builtInRecipes.firstWhere(
      (recipe) => recipe.title == 'Caramel Macchiato',
    );
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
        title: 'Tebak Kopi',
        subtitle: 'Uji lidahmu',
        screen: const TebakKopiScreen(),
        iconBackground: AppColors.ivoryWhite,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.darkCoffee,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
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
                        onPressed: onProfileTap,
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
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.mediumCoffee,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.lightCream.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightCream.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'REKOMENDASI',
                            style: TextStyle(
                              color: AppColors.ivoryWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          recommendedRecipe.title,
                          style: TextStyle(
                            color: AppColors.ivoryWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recommendedRecipe.category} • Resep pilihan dari Buku Resep',
                          style: TextStyle(
                            color: AppColors.ivoryWhite.withValues(alpha: 0.88),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => _open(
                            context,
                            RecipeDetailScreen(recipe: recommendedRecipe),
                          ),
                          icon: const Icon(Icons.menu_book_outlined, size: 16),
                          label: const Text('Buka Resep'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkCoffee,
                            backgroundColor: AppColors.ivoryWhite,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
