import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import 'profile_avatars.dart';

/// Hasil `pop` layar ini: [saveOk] jika semua berhasil, atau teks peringatan
/// jika profil tersimpan tetapi sinkronisasi ke tabel `profiles` gagal.
const String saveOk = 'ok';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const String _bucket = 'avatars';

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;

  String _avatarUrl = '';
  Uint8List? _pickedBytes;
  String _pickedMime = 'image/jpeg';
  bool _removeRequested = false;
  bool _isSaving = false;

  bool get _hasPhoto =>
      _pickedBytes != null || (_avatarUrl.isNotEmpty && !_removeRequested);

  @override
  void initState() {
    super.initState();
    final metadata =
        Supabase.instance.client.auth.currentUser?.userMetadata ?? {};
    _nameController = TextEditingController(
      text: metadata['full_name']?.toString() ?? '',
    );
    _avatarUrl = metadata['avatar_url']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _mimeFor(XFile file) {
    final mime = file.mimeType;
    if (mime != null && mime.startsWith('image/')) {
      return mime;
    }
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null) {
        return; // dibatalkan
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _pickedBytes = bytes;
        _pickedMime = _mimeFor(file);
        _removeRequested = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka galeri: $error')));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ivoryWhite,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.darkCoffee,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickFromGallery();
              },
            ),
            if (_hasPhoto)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[800]),
                title: const Text('Hapus Foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  setState(() {
                    _pickedBytes = null;
                    _removeRequested = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis, silakan login ulang.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final path = '${user.id}/avatar';
    var avatarUrl = _removeRequested ? '' : _avatarUrl;

    try {
      if (_pickedBytes != null) {
        await client.storage
            .from(_bucket)
            .uploadBinary(
              path,
              _pickedBytes!,
              fileOptions: FileOptions(upsert: true, contentType: _pickedMime),
            );
        // Parameter ?v= mengubah URL tiap unggah agar cache gambar diperbarui.
        avatarUrl =
            '${client.storage.from(_bucket).getPublicUrl(path)}'
            '?v=${DateTime.now().millisecondsSinceEpoch}';
      } else if (_removeRequested && _avatarUrl.isNotEmpty) {
        try {
          await client.storage.from(_bucket).remove([path]);
        } catch (error) {
          debugPrint('Hapus file avatar gagal: $error');
        }
      }

      await client.auth.updateUser(
        UserAttributes(data: {'full_name': name, 'avatar_url': avatarUrl}),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $error')),
      );
      return;
    }

    // Sinkronkan ke tabel `profiles` (tidak fatal jika gagal, mis. RLS).
    var result = saveOk;
    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'avatar_url': avatarUrl.isEmpty ? null : avatarUrl,
      });
    } catch (error) {
      debugPrint('Sinkron tabel profiles gagal: $error');
      result =
          'Profil tersimpan, tetapi sinkron ke tabel profiles gagal: $error';
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _showPhotoOptions,
                  child: Stack(
                    children: [
                      ProfileAvatar(
                        radius: 56,
                        imageUrl: _removeRequested ? null : _avatarUrl,
                        memoryBytes: _pickedBytes,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.darkCoffee,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.ivoryWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isSaving ? null : _showPhotoOptions,
                child: const Text('Ubah Foto Profil'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkCoffee,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ivoryWhite,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
