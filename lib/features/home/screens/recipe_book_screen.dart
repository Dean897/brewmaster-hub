import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';
import '../../../core/widgets/recipe_image.dart';
import '../models/recipe_catalog.dart';
import '../models/recipe_model.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeBookScreen extends StatefulWidget {
  const RecipeBookScreen({super.key});

  @override
  State<RecipeBookScreen> createState() => _RecipeBookScreenState();
}

class _RecipeBookScreenState extends State<RecipeBookScreen> {
  final _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final _categories = const [
    'Semua',
    'Manual Brew',
    'Espresso Based',
    'Cold Brew',
    'Mocktail / Coffee Soda',
  ];
  List<Recipe> _communityRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  List<Recipe> get _filteredRecipes {
    final allRecipes = [...builtInRecipes, ..._communityRecipes];
    return allRecipes.where((recipe) {
      final title = recipe.title.toLowerCase();
      final category = recipe.category;
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Semua' || category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) {
        return;
      }

      setState(() {
        _communityRecipes = (response as List<dynamic>)
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat resep: $error';
      });
    }
  }

  Future<void> _openAddRecipe() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const AddRecipeScreen()),
    );

    if (result == true) {
      await _fetchRecipes();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filteredRecipes;

    return Scaffold(
      appBar: coffeeAppBar(
        title: 'Buku Resep',
        actions: [
          IconButton(
            onPressed: _openAddRecipe,
            icon: const Icon(Icons.add),
            tooltip: 'Tambah resep',
          ),
        ],
      ),
      backgroundColor: AppColors.ivoryWhite,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRecipe,
        backgroundColor: AppColors.darkCoffee,
        foregroundColor: AppColors.ivoryWhite,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
                fillColor: AppColors.lightCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  selectedColor: AppColors.darkCoffee,
                  backgroundColor: AppColors.lightCream,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category
                        ? AppColors.ivoryWhite
                        : AppColors.darkCoffee,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.mediumCoffee,
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.darkCoffee),
                      ),
                    ),
                  )
                : recipes.isEmpty
                ? const Center(
                    child: Text(
                      'Resep tidak ditemukan.',
                      style: TextStyle(color: AppColors.mediumCoffee),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      final recipeName = recipe.title;
                      final category = recipe.category;
                      final source = recipe.source;

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
                          leading: RecipeImage(
                            imageUrl: recipe.imageUrl,
                            width: 64,
                            height: 64,
                            borderRadius: 12,
                            iconSize: 28,
                          ),
                          title: Text(
                            recipeName,
                            style: const TextStyle(
                              color: AppColors.darkCoffee,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '$category • $source',
                            style: const TextStyle(
                              color: AppColors.mediumCoffee,
                            ),
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
                                builder: (_) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
