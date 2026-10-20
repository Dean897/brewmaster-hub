import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  static const _articles = [
    (
      title: 'Rahasia Cold Brew Anti Gagal',
      description: 'Panduan membuat cold brew yang lembut dan menyegarkan.',
    ),
    (
      title: 'Event Yogyakarta Coffee Week',
      description: 'Jelajahi festival kopi dan kedai lokal terbaik di Yogyakarta.',
    ),
    (
      title: 'Mengenal Biji Kopi Gayo',
      description: 'Kenali karakter rasa dan asal biji kopi Gayo dari Aceh.',
    ),
    (
      title: 'Tips V60 untuk Pemula',
      description: 'Langkah sederhana menyeduh V60 dengan rasa yang seimbang.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal & Event'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shadowColor: AppColors.mediumCoffee.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.mediumCoffee,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.coffee,
                        color: AppColors.lightCream,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: AppColors.darkCoffee,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.description,
                            style: const TextStyle(
                              color: AppColors.mediumCoffee,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.darkCoffee,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
