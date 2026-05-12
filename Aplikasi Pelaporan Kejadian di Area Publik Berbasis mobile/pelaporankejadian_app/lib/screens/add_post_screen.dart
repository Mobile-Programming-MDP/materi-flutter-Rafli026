import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../state/app_state.dart';
import 'map_screen.dart';

class AddPostScreen extends StatefulWidget {
  static const route = '/add';

  final AppState appState;

  const AddPostScreen({super.key, required this.appState});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descCtrl = TextEditingController();

  static const List<String> _categories = [
    'Kecelakaan',
    'Kebakaran',
    'Kerusuhan',
    'Bencana Alam',
    'Gangguan Lalu Lintas',
    'Kriminalitas',
    'Lainnya',
  ];

  String _selectedCategory = _categories.first;

  bool _loadingLoc = false;
  bool _loadingImg = false;
  bool _loadingPost = false;

  Uint8List? _imageBytes;
  String? _imagePath;

  double? _latitude;
  double? _longitude;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked == null) return;

    setState(() => _loadingImg = true);

    final bytes = await picked.readAsBytes();
    Uint8List imageBytes = bytes;

    if (!kIsWeb) {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 70,
      );

      if (compressed.isNotEmpty) {
        imageBytes = Uint8List.fromList(compressed);
      }
    }

    setState(() {
      _imageBytes = imageBytes;
      _imagePath = picked.path;
      _loadingImg = false;
    });
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLoc = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Location service tidak aktif');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal ambil lokasi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loadingLoc = false);
      }
    }
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();

    if (desc.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deskripsi wajib diisi')));
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi belum dipilih')));
      return;
    }

    setState(() => _loadingPost = true);

    try {
      await widget.appState.addPost(
        category: _selectedCategory,
        description: desc,
        latitude: _latitude!,
        longitude: _longitude!,
        imagePath: _imagePath,
        imageBytes: _imageBytes,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post berhasil disimpan')));

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() => _loadingPost = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan post: $e')));
    }
  }

  void _showImagePickerOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Kategori'),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          const Text('Deskripsi'),
          const SizedBox(height: 8),

          TextField(
            controller: _descCtrl,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Ceritakan kejadian...',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          const Text('Gambar'),
          const SizedBox(height: 8),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _loadingImg ? null : _showImagePickerOption,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Pilih Gambar'),
              ),

              const SizedBox(width: 10),

              if (_loadingImg)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (_imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _imageBytes!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 20),

          const Text('Lokasi'),
          const SizedBox(height: 8),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _loadingLoc ? null : _getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Ambil Lokasi'),
              ),

              const SizedBox(width: 10),

              if (_loadingLoc)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (_latitude != null && _longitude != null)
            Text(
              'Lat/Lng: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
            ),

          const SizedBox(height: 16),

          if (_latitude != null && _longitude != null)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  MapScreen.route,
                  arguments: {
                    'lat': _latitude!,
                    'lng': _longitude!,
                    'title': _selectedCategory,
                  },
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Buka Map'),
            ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _loadingPost ? null : _save,
            icon: const Icon(Icons.check_circle_outline),
            label: _loadingPost
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan Post'),
          ),
        ],
      ),
    );
  }
}
