import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../minigames/screens/gacha_screen.dart';
import 'timer_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      (icon: Icons.map_outlined, title: 'Peta Kedai'),
      (icon: Icons.menu_book_outlined, title: 'Buku Resep'),
      (icon: Icons.screen_rotation_outlined, title: 'Kocok Resep'),
      (icon: Icons.coffee_maker_outlined, title: 'Pour-Over Challenge'),
      (icon: Icons.help_outline, title: 'Tebak Kopi'),
      (icon: Icons.alarm_outlined, title: 'Timer Seduh'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo, Barista!',
            style: TextStyle(
              color: AppColors.darkCoffee,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final menu in menus)
                _MenuCard(
                  icon: menu.icon,
                  title: menu.title,
                  onTap: () {
                    if (menu.title == 'Timer Seduh') {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const TimerScreen(),
                        ),
                      );
                    } else if (menu.title == 'Kocok Resep') {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const GachaScreen(),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCream,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.mediumCoffee,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkCoffee,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
