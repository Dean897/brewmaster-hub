class Recipe {
  const Recipe({
    required this.title,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.duration,
    required this.source,
    this.imageUrl,
  });

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    String source = 'Resep Komunitas',
  }) {
    return Recipe(
      title: json['title']?.toString() ?? 'Tanpa Judul',
      category: json['category']?.toString() ?? 'Tanpa Kategori',
      ingredients: json['ingredients']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      duration: _parseDuration(json['duration']),
      source: source,
      imageUrl: json['image_url']?.toString(),
    );
  }

  /// Kunci unik resep (dipakai untuk menandai resep favorit).
  String get key => '$source|$title';

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'ingredients': ingredients,
    'instructions': instructions,
    'duration': duration,
    'source': source,
    'image_url': imageUrl,
  };

  final String title;
  final String category;
  final String ingredients;
  final String instructions;
  final int duration;
  final String source;
  final String? imageUrl;

  static int _parseDuration(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
