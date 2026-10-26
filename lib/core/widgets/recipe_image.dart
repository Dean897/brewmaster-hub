import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Widget reusable untuk menampilkan gambar resep dengan logika fallback:
///
/// 1. Jika [imageUrl] **null/kosong** → tampilkan ikon kopi default.
/// 2. Jika [imageUrl] berawalan `http` → gunakan [Image.network].
/// 3. Selain itu → gunakan [Image.asset] (aset lokal).
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.iconSize = 48,
    super.key,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    // Fallback: ikon kopi default
    if (url.isEmpty) {
      return _placeholder();
    }

    // Network image (URL dari Supabase Storage, dsb.)
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _loadingPlaceholder();
          },
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }

    // Local asset
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.mediumCoffee,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(Icons.coffee, color: AppColors.lightCream, size: iconSize),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.mediumCoffee,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
