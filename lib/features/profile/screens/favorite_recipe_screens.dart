import 'package:flutter/material.dart';

import '../../../../core/services/favorite_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home/models/recipe_model.dart';
import '../../home/screens/recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  @override
  void initState() {
    super.initState();
    FavoriteService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Resep Favorit Saya'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: ValueListenableBuilder<List<Recipe>>(
        valueListenable: FavoriteService.instance.favorites,
        builder: (context, recipes, _) {
          if (recipes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: AppColors.mediumCoffee,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada resep favorit.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCoffee,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Buka detail resep di Buku Resep, lalu ketuk ikon '
                      'bookmark untuk menyimpannya di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mediumCoffee),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                color: AppColors.lightCream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.mediumCoffee,
                    foregroundColor: AppColors.lightCream,
                    child: Icon(Icons.coffee),
                  ),
                  title: Text(
                    recipe.title,
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${recipe.category} • ${recipe.source}',
                    style: const TextStyle(color: AppColors.mediumCoffee),
                  ),
                  trailing: IconButton(
                    tooltip: 'Hapus dari favorit',
                    icon: const Icon(
                      Icons.bookmark,
                      color: AppColors.darkCoffee,
                    ),
                    onPressed: () => FavoriteService.instance.toggle(recipe),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
