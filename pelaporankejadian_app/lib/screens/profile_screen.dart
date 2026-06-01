import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/profile';

  final AppState appState;

  const ProfileScreen({super.key, required this.appState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  Uint8List? _selectedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentUser = widget.appState.currentUser;
    _nameController.text = currentUser?.name ?? '';
    if (currentUser?.photoBase64 != null) {
      _selectedPhoto = base64Decode(currentUser!.photoBase64!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _selectedPhoto = bytes;
    });
  }

  Future<void> _saveProfile() async {
    if (widget.appState.currentUser == null) return;
    setState(() {
      _isSaving = true;
    });

    final photoBase64 = _selectedPhoto != null
        ? base64Encode(_selectedPhoto!)
        : null;
    final name = _nameController.text.trim();

    final error = await widget.appState.updateProfile(
      name: name.isEmpty ? widget.appState.currentUser?.name : name,
      photoBase64: photoBase64,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error == null ? 'Profil berhasil diperbarui' : error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: _selectedPhoto != null
                    ? ClipOval(
                        child: Image.memory(
                          _selectedPhoto!,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: false,
              initialValue: user.email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ID Akun: ${user.id}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Pilih Foto Profil'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: _isSaving
                  ? const Text('Menyimpan...')
                  : const Text('Simpan Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
