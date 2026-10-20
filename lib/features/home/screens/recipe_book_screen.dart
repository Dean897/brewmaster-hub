import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'recipe_detail_screen.dart';

class RecipeBookScreen extends StatelessWidget {
  const RecipeBookScreen({super.key});

  static const _recipes = [
    'V60 Manual Brew',
    'Caramel Macchiato',
    'Cold Brew',
    'Espresso Tonic',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Resep'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipeName = _recipes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            shadowColor: AppColors.mediumCoffee.withValues(alpha: 0.25),
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
                recipeName,
                style: const TextStyle(
                  color: AppColors.darkCoffee,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Lihat bahan dan cara membuat',
                style: TextStyle(color: AppColors.mediumCoffee),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.darkCoffee,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => RecipeDetailScreen(
                      recipeName: recipeName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
