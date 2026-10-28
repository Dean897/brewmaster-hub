import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/models/recipe_model.dart';

/// Menyimpan resep favorit per-akun di penyimpanan lokal perangkat.
///
/// Data disimpan di SharedPreferences dengan kunci yang memuat id user,
/// sehingga tiap akun di perangkat yang sama punya daftar favorit sendiri.
class FavoriteService {
  FavoriteService._();

  static final FavoriteService instance = FavoriteService._();

  final ValueNotifier<List<Recipe>> favorites = ValueNotifier<List<Recipe>>(
    const [],
  );

  String? _loadedForUser;

  String get _userId {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  String get _storageKey => 'favorite_recipes_$_userId';

  /// Memuat favorit dari penyimpanan. Dimuat ulang otomatis jika akun berganti.
  Future<void> ensureLoaded() async {
    if (_loadedForUser == _userId) {
      return;
    }
    final userId = _userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('favorite_recipes_$userId') ?? const [];

    final recipes = <Recipe>[];
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        recipes.add(
          Recipe.fromJson(
            map,
            source: map['source']?.toString() ?? 'Resep Komunitas',
          ),
        );
      } catch (error) {
        debugPrint('Favorit rusak dilewati: $error');
      }
    }

    favorites.value = recipes;
    _loadedForUser = userId;
  }

  bool isFavorite(Recipe recipe) =>
      favorites.value.any((item) => item.key == recipe.key);

  /// Menambah/menghapus favorit. Mengembalikan `true` jika kini jadi favorit.
  Future<bool> toggle(Recipe recipe) async {
    await ensureLoaded();

    final current = [...favorites.value];
    final index = current.indexWhere((item) => item.key == recipe.key);
    final nowFavorite = index < 0;
    if (nowFavorite) {
      current.insert(0, recipe);
    } else {
      current.removeAt(index);
    }

    favorites.value = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      current.map((item) => jsonEncode(item.toJson())).toList(),
    );
    return nowFavorite;
  }
}
