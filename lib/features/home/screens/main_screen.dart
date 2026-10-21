import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../ai_assistant/screens/ai_chat_tab.dart';
import '../../news/screens/news_tab.dart';
import 'home_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    AiChatTab(),
    NewsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.lightCream,
        selectedItemColor: AppColors.darkCoffee,
        unselectedItemColor: AppColors.mediumCoffee,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: 'Asisten AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
            activeIcon: Icon(Icons.public),
            label: 'Info Global',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Fungsi Logout
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    try {
      await AuthService().signOut();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout gagal: $error')));
      }
      return;
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Dialog Edit Profil
  void _showEditProfileDialog() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final nameController = TextEditingController(
      text: currentUser?.userMetadata?['full_name'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkCoffee,
            ),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(
                    data: {'full_name': nameController.text.trim()},
                  ),
                );

                if (mounted) {
                  setState(() {}); // Memperbarui UI seketika tanpa refresh
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui profil: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog Tentang Aplikasi
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BrewMaster Hub',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(
        Icons.coffee,
        size: 40,
        color: AppColors.darkCoffee,
      ),
      children: const [
        SizedBox(height: 10),
        Text(
          'BrewMaster Hub adalah aplikasi panduan dan pencatatan resep seduh kopi untuk para pencinta kopi.',
        ),
        SizedBox(height: 8),
        Text(
          'Dikembangkan oleh Kelompok BrewMaster Team.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final email = currentUser?.email ?? 'Email tidak ditemukan';
    final fullName =
        currentUser?.userMetadata?['full_name'] as String? ??
        'Pengguna BrewMaster';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.lightCream,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.darkCoffee,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
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
                  // Badge / Label Status
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
                    child: const Text(
                      'Coffee Enthusiast',
                      style: TextStyle(
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

            // B. MENU AKTIVITAS / RINGKASAN (Card Row)
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: AppColors.lightCream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.mediumCoffee,
                        width: 0.5,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            '12',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkCoffee,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Resep Tersimpan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumCoffee,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: AppColors.lightCream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.mediumCoffee,
                        width: 0.5,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'Barista Novice',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkCoffee,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Level Seduh',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumCoffee,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // C. DAFTAR MENU PENGATURAN (Card ListTile)
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
                    onTap: _showEditProfileDialog,
                  ),
                  const Divider(height: 1, color: AppColors.mediumCoffee),
                  ListTile(
                    leading: const Icon(
                      Icons.bookmark,
                      color: AppColors.darkCoffee,
                    ),
                    title: const Text('Resep Favorit Saya'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur Resep Favorit sedang dikembangkan',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.mediumCoffee),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: AppColors.darkCoffee,
                    ),
                    title: const Text('Tentang BrewMaster Hub'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // D. TOMBOL LOGOUT
            OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
