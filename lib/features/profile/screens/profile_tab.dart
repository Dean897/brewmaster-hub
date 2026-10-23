import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/models/recipe_model.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/favorite_recipe_screens.dart';
import '../screens/loyalty_stamps_screen.dart';
import 'profile_avatars.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const List<String> _teamMembers = [
    'Deandra Naufal Maulana (124240186)',
    'Habrian Daffa Dwiyandana (124240126)',
    'Muhammad Titan Deannova (124240152)',
  ];
  static const String _appVersion = '0.1.0';

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    FavoriteService.instance.ensureLoaded();
  }

  /// Level & badge ditentukan dari jumlah resep favorit.
  ({String level, String badge}) _rankFor(int savedCount) {
    if (savedCount >= 10) {
      return (level: 'Master Brewer', badge: 'Master Brewer');
    }
    if (savedCount >= 6) {
      return (level: 'Skilled Barista', badge: 'Coffee Connoisseur');
    }
    if (savedCount >= 3) {
      return (level: 'Home Brewer', badge: 'Coffee Lover');
    }
    return (level: 'Barista Novice', badge: 'Coffee Enthusiast');
  }

  String _memberSince(User? user) {
    final date = DateTime.tryParse(user?.createdAt ?? '')?.toLocal();
    if (date == null) {
      return '-';
    }
    return '${_months[date.month - 1]} ${date.year}';
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const EditProfileScreen()),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {}); // baca ulang metadata user terbaru
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == saveOk ? 'Profil berhasil diperbarui!' : result,
        ),
      ),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FavoriteRecipesScreen()),
    );
  }

  void _openLoyaltyStamps() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoyaltyStampsScreen()),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'BrewMaster Hub',
      applicationVersion: 'v$_appVersion',
      applicationIcon: const Icon(
        Icons.coffee,
        size: 40,
        color: AppColors.darkCoffee,
      ),
      children: [
        const SizedBox(height: 10),
        const Text(
          'BrewMaster Hub adalah aplikasi mobile komprehensif dirancang khusus untuk '
          'para pecinta kopi dan home brewer. Aplikasi ini tidak hanya berfungsi'
          'sebagai panduan menyeduh kopi, tetapi juga sebagai asisten pintar,'
          'pencari kedai kopi terdekat berbasis lokasi (Located-Based Service),'
          'dan platform hiburan interaktif (minigame)',
        ),
        const SizedBox(height: 12),
        const Text(
          'Dikembangkan oleh:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        for (final member in _teamMembers) Text('• $member'),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    try {
      await AuthService().signOut();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout gagal: $error')));
      }
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: AppColors.lightCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.mediumCoffee, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCoffee,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumCoffee,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final email = user?.email ?? 'Email tidak ditemukan';
    final rawName = (metadata?['full_name'] as String?)?.trim();
    final fullName = (rawName == null || rawName.isEmpty)
        ? 'Pengguna BrewMaster'
        : rawName;
    final avatarUrl = metadata?['avatar_url'] as String?;

    return SafeArea(
      child: ValueListenableBuilder<List<Recipe>>(
        valueListenable: FavoriteService.instance.favorites,
        builder: (context, favorites, _) {
          final rank = _rankFor(favorites.length);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Profil & Akun',
                        style: TextStyle(
                          color: AppColors.darkCoffee,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // A. HEADER PROFIL PENGGUNA
                      Center(
                        child: Column(
                          children: [
                            ProfileAvatar(radius: 48, imageUrl: avatarUrl),
                            const SizedBox(height: 16),
                            Text(
                              fullName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCoffee,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumCoffee,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightCream,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.mediumCoffee,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                rank.badge,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkCoffee,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // B. RINGKASAN AKTIVITAS
                      Row(
                        children: [
                          _statCard(
                            value: '${favorites.length}',
                            label: 'Resep Tersimpan',
                          ),
                          const SizedBox(width: 12),
                          _statCard(value: rank.level, label: 'Level Seduh'),
                          const SizedBox(width: 12),
                          _statCard(
                            value: _memberSince(user),
                            label: 'Bergabung',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // C. DAFTAR MENU PENGATURAN
                      Card(
                        elevation: 0,
                        color: AppColors.lightCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColors.mediumCoffee,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.edit,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Edit Profil'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openEditProfile,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.bookmark,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Resep Favorit Saya'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openFavorites,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.card_giftcard,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Loyalty Stamps'),
                              subtitle: const Text('Kumpulkan 10 stempel kopi'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openLoyaltyStamps,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.info_outline,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Tentang BrewMaster Hub'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _showAboutDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // D. TOMBOL LOGOUT (tetap di bagian bawah layar)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
