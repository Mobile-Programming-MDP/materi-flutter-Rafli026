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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
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
      if (!serviceEnabled) throw Exception('Location service tidak aktif');

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
      if (mounted) setState(() => _loadingLoc = false);
    }
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    final category = _selectedCategory;

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
        category: category,
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
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingPost = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan post: $e')));
    }
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
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 18),

          const Text('Gambar'),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _loadingImg ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Pilih'),
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
                height: 180,
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
                icon: const Icon(Icons.my_location_outlined),
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
              style: Theme.of(context).textTheme.bodySmall,
            ),

          const SizedBox(height: 14),
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
              icon: const Icon(Icons.map_outlined),
              label: const Text('Buka Map'),
            ),

          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _loadingPost ? null : _save,
            icon: const Icon(Icons.check_circle_outline),
            label: _loadingPost
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan Post'),
          ),
        ],
      ),
    );
  }
}
