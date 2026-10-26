import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/models/recipe_catalog.dart';
import '../../features/home/models/recipe_model.dart';
import 'favorite_service.dart';

/// Sistem rekomendasi resep menggunakan **Content-Based Filtering**.
///
/// Algoritma:
/// 1. Ambil daftar resep favorit pengguna dari [FavoriteService].
/// 2. Hitung frekuensi kemunculan setiap **kategori** (fitur) pada resep
///    favorit — hasilnya disebut *profil preferensi pengguna*.
/// 3. Hitung **skor kecocokan** setiap resep kandidat terhadap profil
///    preferensi tersebut menggunakan bobot frekuensi ternormalisasi.
/// 4. Urutkan resep berdasarkan skor tertinggi, saring yang sudah difavoritkan,
///    dan kembalikan 3-5 rekomendasi teratas.
/// 5. Jika pengguna belum punya favorit (*cold start*), kembalikan resep
///    acak dari katalog bawaan.
class RecommendationService {
  RecommendationService._();

  static final RecommendationService instance = RecommendationService._();

  final _random = Random();

  // ─────────────────────────── public API ────────────────────────────

  /// Mengembalikan 3-5 resep rekomendasi berdasarkan preferensi pengguna.
  ///
  /// Secara otomatis menangani *cold start* ketika pengguna belum memiliki
  /// resep favorit.
  Future<List<Recipe>> getSmartRecommendations() async {
    // Pastikan data favorit sudah dimuat.
    final favService = FavoriteService.instance;
    await favService.ensureLoaded();
    final favorites = favService.favorites.value;

    // Kumpulkan seluruh pool resep (lokal + komunitas dari Supabase).
    final allRecipes = await _buildRecipePool();

    // --- Cold Start Handling ---
    if (favorites.isEmpty) {
      return _coldStartRecommendations(allRecipes);
    }

    // --- Langkah 1: Ekstraksi Fitur (Profil Preferensi Pengguna) ---
    final categoryProfile = _buildCategoryProfile(favorites);

    // --- Langkah 2: Scoring Setiap Resep Kandidat ---
    final favoriteKeys = favorites.map((r) => r.key).toSet();
    final scored = <_ScoredRecipe>[];

    for (final recipe in allRecipes) {
      // Wajib filter: jangan rekomendasikan yang sudah difavoritkan.
      if (favoriteKeys.contains(recipe.key)) continue;

      final score = _calculateScore(recipe, categoryProfile);
      if (score > 0) {
        scored.add(_ScoredRecipe(recipe: recipe, score: score));
      }
    }

    // --- Langkah 3: Urutkan dan Ambil Top-N ---
    scored.sort((a, b) => b.score.compareTo(a.score));

    // Ambil maksimal 5 rekomendasi.
    final topResults = scored.take(5).map((s) => s.recipe).toList();

    // Jika hasil kurang dari 3, tambahkan resep acak untuk melengkapi.
    if (topResults.length < 3) {
      final remaining = allRecipes
          .where((r) =>
              !favoriteKeys.contains(r.key) &&
              !topResults.any((t) => t.key == r.key))
          .toList();
      remaining.shuffle(_random);
      for (final recipe in remaining) {
        topResults.add(recipe);
        if (topResults.length >= 3) break;
      }
    }

    return topResults;
  }

  // ─────────────────────── internal helpers ──────────────────────────

  /// Mengumpulkan semua resep dari katalog bawaan + tabel Supabase `recipes`.
  Future<List<Recipe>> _buildRecipePool() async {
    final pool = <Recipe>[...builtInRecipes];

    try {
      final response = await Supabase.instance.client
          .from('recipes')
          .select()
          .order('created_at', ascending: false);

      final communityRecipes = (response as List<dynamic>)
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();

      pool.addAll(communityRecipes);
    } catch (error) {
      // Jika fetch komunitas gagal, gunakan resep bawaan saja.
      debugPrint('RecommendationService: gagal memuat resep komunitas — $error');
    }

    return pool;
  }

  /// Menghitung frekuensi kemunculan setiap kategori dari resep favorit
  /// pengguna dan mengembalikan bobot ternormalisasi (0..1).
  ///
  /// Contoh output: `{ 'Manual Brew': 0.6, 'Cold Brew': 0.4 }`
  Map<String, double> _buildCategoryProfile(List<Recipe> favorites) {
    final frequency = <String, int>{};

    for (final recipe in favorites) {
      final category = recipe.category.trim();
      frequency[category] = (frequency[category] ?? 0) + 1;
    }

    // Normalisasi: bagi setiap frekuensi dengan jumlah total favorit.
    final total = favorites.length.toDouble();
    return frequency.map((category, count) => MapEntry(category, count / total));
  }

  /// Menghitung skor kecocokan resep terhadap profil preferensi pengguna.
  ///
  /// Skor = bobot ternormalisasi dari kategori resep tersebut.
  /// Jika kategori tidak ada di profil, skor = 0.
  double _calculateScore(Recipe recipe, Map<String, double> profile) {
    return profile[recipe.category.trim()] ?? 0.0;
  }

  /// Menangani *cold start*: pengguna belum punya resep favorit.
  ///
  /// Mengembalikan 3-5 resep acak dari pool sebagai rekomendasi default
  /// agar halaman beranda tidak terlihat kosong.
  List<Recipe> _coldStartRecommendations(List<Recipe> pool) {
    if (pool.isEmpty) return const [];

    final shuffled = [...pool]..shuffle(_random);
    return shuffled.take(min(5, shuffled.length)).toList();
  }
}

/// Internal helper: menyimpan resep bersama skor kecocokannya.
class _ScoredRecipe {
  const _ScoredRecipe({required this.recipe, required this.score});
  final Recipe recipe;
  final double score;
}
