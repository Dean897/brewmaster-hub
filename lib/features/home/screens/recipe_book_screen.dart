import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
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
  static const _builtInRecipes = [
    Recipe(
      title: 'V60 Manual Brew',
      category: 'Manual Brew',
      ingredients: '''15g Biji kopi (giling medium)
225ml Air panas (suhu 90-93°C)
1 lembar Kertas filter V60''',
      instructions: '''1. Letakkan kertas filter pada dripper V60, bilas dengan air panas, lalu buang air bilasan.
2. Masukkan bubuk kopi ke dalam filter, ratakan permukaannya.
3. Tuang 30ml air perlahan (proses blooming), tunggu sekitar 30 detik.
4. Tuang sisa air secara melingkar dan perlahan hingga mencapai total 225ml.
5. Tunggu hingga semua air turun (waktu ideal sekitar 2.5 menit). Angkat dripper dan sajikan.''',
      duration: 5,
      source: 'Resep Utama',
    ),
    Recipe(
      title: 'Caramel Macchiato',
      category: 'Espresso Based',
      ingredients: '''1 shot Espresso (30ml)
150ml Susu Segar (Fresh Milk)
15ml Sirup Vanilla
10ml Saus Karamel (Caramel Sauce)
Es batu secukupnya (jika disajikan dingin)''',
      instructions: '''1. Tuangkan sirup vanilla ke dasar gelas.
2. (Opsional untuk dingin) Masukkan es batu hingga gelas hampir penuh.
3. Tuangkan susu segar ke dalam gelas, lalu aduk perlahan dengan sirup vanilla.
4. Tuangkan tembakan espresso tepat di tengah agar membentuk gradasi (macchiato/bercak).
5. Hias bagian atas minuman dengan pola silang menggunakan saus karamel.''',
      duration: 5,
      source: 'Resep Utama',
    ),
    Recipe(
      title: 'Classic Cold Brew',
      category: 'Cold Brew',
      ingredients: '''50g Biji kopi (giling kasar / coarse)
500ml Air mineral bersuhu ruang''',
      instructions: '''1. Masukkan bubuk kopi ke dalam wadah tertutup (mason jar atau botol kaca).
2. Tuangkan air secara perlahan, aduk rata agar semua bubuk kopi basah sempurna.
3. Tutup rapat wadah dan simpan di dalam kulkas selama 12 hingga 24 jam.
4. Keluarkan dari kulkas, lalu saring ampas kopi menggunakan kertas saring atau saringan kain bersih.
5. Sajikan dingin (bisa ditambahkan es batu atau sedikit susu/krim cair sesuai selera).''',
      duration: 720,
      source: 'Resep Utama',
    ),
    Recipe(
      title: 'Espresso Tonic',
      category: 'Mocktail / Coffee Soda',
      ingredients: '''1 shot Espresso (30ml), sebaiknya kopi dengan fruity notes
120ml Air Tonik (Tonic Water) dingin
1 iris Lemon atau Jeruk Nipis (untuk garnish)
Es batu secukupnya''',
      instructions: '''1. Siapkan gelas berukuran sedang, isi dengan es batu hingga penuh.
2. Tuangkan air tonik dingin perlahan ke dalam gelas (hindari menuang terlalu cepat agar sodanya tidak meluap).
3. Ekstrak 1 shot espresso dan segera tuangkan secara perlahan ke atas air tonik.
4. Tambahkan irisan lemon atau jeruk nipis di pinggir atau di dalam gelas.
5. Minuman siap disajikan (aduk rata sebelum diminum agar rasanya seimbang).''',
      duration: 5,
      source: 'Resep Utama',
    ),
  ];

  List<Recipe> _communityRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  List<Recipe> get _filteredRecipes {
    final allRecipes = [..._builtInRecipes, ..._communityRecipes];
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
            .map(
              (recipe) => Recipe.fromJson(
                recipe as Map<String, dynamic>,
              ),
            )
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
      appBar: AppBar(
        title: const Text('Buku Resep'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
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
                                builder: (_) => RecipeDetailScreen(
                                  recipe: recipe,
                                ),
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
