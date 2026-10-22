import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

AppBar coffeeAppBar({required String title, List<Widget> actions = const []}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: AppColors.darkCoffee,
    foregroundColor: AppColors.ivoryWhite,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    actions: actions,
  );
}
