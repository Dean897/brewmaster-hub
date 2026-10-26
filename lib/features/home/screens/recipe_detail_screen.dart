import 'package:flutter/material.dart';

import '../../../core/services/favorite_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({required this.recipe, super.key});

  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe get recipe => widget.recipe;

  @override
  void initState() {
    super.initState();
    FavoriteService.instance.ensureLoaded();
  }

  Future<void> _toggleFavorite() async {
    final nowFavorite = await FavoriteService.instance.toggle(recipe);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            nowFavorite
                ? 'Ditambahkan ke Resep Favorit'
                : 'Dihapus dari Resep Favorit',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
        actions: [
          ValueListenableBuilder<List<Recipe>>(
            valueListenable: FavoriteService.instance.favorites,
            builder: (context, _, _) {
              final isFavorite = FavoriteService.instance.isFavorite(recipe);
              return IconButton(
                onPressed: _toggleFavorite,
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Simpan ke favorit',
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.darkCoffee,
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.mediumCoffee,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.coffee,
                color: AppColors.lightCream,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bahan-bahan',
              style: TextStyle(
                color: AppColors.darkCoffee,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.ingredients.isEmpty
                  ? 'Bahan belum tersedia.'
                  : recipe.ingredients,
              style: const TextStyle(color: AppColors.darkCoffee),
            ),
            const SizedBox(height: 24),
            const Text(
              'Langkah Pembuatan',
              style: TextStyle(
                color: AppColors.darkCoffee,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.instructions.isEmpty
                  ? 'Langkah pembuatan belum tersedia.'
                  : recipe.instructions,
              style: const TextStyle(color: AppColors.darkCoffee),
            ),
          ],
        ),
      ),
    );
  }
}
