import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Avatar bulat: menampilkan foto (dari URL atau byte lokal) bila ada,
/// dan ikon orang sebagai cadangan bila foto kosong / gagal dimuat.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.radius,
    this.imageUrl,
    this.memoryBytes,
    super.key,
  });

  final double radius;
  final String? imageUrl;
  final Uint8List? memoryBytes;

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = memoryBytes != null
        ? MemoryImage(memoryBytes!)
        : (imageUrl != null && imageUrl!.isNotEmpty)
        ? NetworkImage(imageUrl!)
        : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightCream,
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Icon(
        Icons.person,
        size: radius * 1.1,
        color: AppColors.darkCoffee,
      ),
    );
  }
}
