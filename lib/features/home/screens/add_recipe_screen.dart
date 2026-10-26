import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _durationController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  static const _categories = [
    'Espresso Based',
    'Manual Brew',
    'Cold Brew',
    'Mocktail / Coffee Soda',
  ];
  String _category = _categories.first;
  bool _isSaving = false;
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // ─── Image Picker ──────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.darkCoffee,
                ),
                title: const Text('Ambil Foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.darkCoffee,
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ─── Upload Image to Supabase Storage ─────────────────────────────

  /// Mengunggah gambar ke bucket `recipe_images` dan mengembalikan URL publik.
  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    final ext = p.extension(_selectedImage!.path).replaceAll('.', '');
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = 'recipes/$fileName';

    await _supabase.storage
        .from('recipe_images')
        .upload(storagePath, _selectedImage!);

    final publicUrl = _supabase.storage
        .from('recipe_images')
        .getPublicUrl(storagePath);

    return publicUrl;
  }

  // ─── Save Recipe ──────────────────────────────────────────────────

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showMessage('Anda harus login untuk menambahkan resep.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Upload gambar jika ada.
      final imageUrl = await _uploadImage(user.id);

      await _supabase.from('recipes').insert({
        'author_id': user.id,
        'title': _titleController.text.trim(),
        'category': _category,
        'ingredients': _ingredientsController.text.trim(),
        'instructions': _stepsController.text.trim(),
        'duration': int.parse(_durationController.text.trim()),
        'image_url': imageUrl,
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal menyimpan resep: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.lightCream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coffeeAppBar(title: 'Tambah Resep'),
      backgroundColor: AppColors.ivoryWhite,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── Image Picker Area ───
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightCream,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.mediumCoffee.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: AppColors.mediumCoffee,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan Foto Resep',
                            style: TextStyle(
                              color: AppColors.mediumCoffee,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk untuk memilih gambar',
                            style: TextStyle(
                              color: AppColors.mediumCoffee.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  setState(() => _selectedImage = null),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Form Fields ───
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('Judul Resep'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Judul wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _inputDecoration('Kategori'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              maxLines: 5,
              decoration: _inputDecoration('Bahan-bahan'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Bahan-bahan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stepsController,
              maxLines: 6,
              decoration: _inputDecoration('Langkah-langkah'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Langkah-langkah wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Durasi (menit)'),
              validator: (value) {
                final duration = int.tryParse(value?.trim() ?? '');
                return duration == null || duration <= 0
                    ? 'Masukkan durasi yang valid'
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _saveRecipe,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkCoffee,
                foregroundColor: AppColors.ivoryWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ivoryWhite,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedImage != null
                              ? 'Mengunggah & menyimpan...'
                              : 'Menyimpan...',
                        ),
                      ],
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
