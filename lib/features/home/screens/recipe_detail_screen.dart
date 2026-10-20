import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({
    required this.recipeName,
    super.key,
  });

  final String recipeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
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
            const _IngredientItem(text: '20 gram biji kopi, digiling medium'),
            const _IngredientItem(text: '250 ml air panas bersuhu 90-94°C'),
            const _IngredientItem(text: 'Es batu secukupnya'),
            const _IngredientItem(text: 'Susu atau pemanis sesuai selera'),
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
            const _StepItem(
              number: 1,
              text: 'Siapkan alat seduh dan bilas filter dengan air panas.',
            ),
            const _StepItem(
              number: 2,
              text: 'Masukkan bubuk kopi, lalu tuangkan air secara perlahan.',
            ),
            const _StepItem(
              number: 3,
              text: 'Tunggu hingga air selesai menetes dan ekstraksi merata.',
            ),
            const _StepItem(
              number: 4,
              text: 'Sajikan kopi selagi hangat atau tambahkan es sesuai selera.',
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  const _IngredientItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.mediumCoffee,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.darkCoffee),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.darkCoffee,
            foregroundColor: AppColors.ivoryWhite,
            child: Text('$number'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.darkCoffee),
            ),
          ),
        ],
      ),
    );
  }
}
