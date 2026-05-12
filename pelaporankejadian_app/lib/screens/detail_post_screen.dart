import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/post.dart';
import '../state/app_state.dart';
import 'map_screen.dart';

class DetailPostScreen extends StatelessWidget {
  static const route = '/detail';

  final String postId;

  const DetailPostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final ReportPost post = appState.posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => appState.posts.first,
    );

    final isOwner = appState.currentUser?.id == post.userId;

    return Scaffold(
      appBar: AppBar(title: Text(post.category)),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // GAMBAR
          if (post.imageBytes != null && post.imageBytes!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                post.imageBytes!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 16),

          // DESKRIPSI
          Text(post.description, style: Theme.of(context).textTheme.bodyLarge),

          const SizedBox(height: 12),

          // WAKTU
          Text(
            'Waktu: ${post.createdAt.toLocal()}'.split('.').first,
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 8),

          // LOKASI
          Text(
            'Lokasi: ${post.latitude.toStringAsFixed(5)}, '
            '${post.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 20),

          // BUTTON MAP
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                MapScreen.route,
                arguments: {
                  'lat': post.latitude,
                  'lng': post.longitude,
                  'title': post.category,
                },
              );
            },
            icon: const Icon(Icons.map),
            label: const Text('Lihat Lokasi di Map'),
          ),

          const SizedBox(height: 16),

          // DELETE POST
          if (isOwner)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () async {
                await appState.deletePost(post.id);

                if (!context.mounted) return;

                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Post'),
            ),

          if (isOwner) const SizedBox(height: 12),

          // SHARE
          ElevatedButton.icon(
            onPressed: () async {
              final text =
                  'Laporan ${post.category}\n'
                  '${post.description}\n'
                  'Lokasi: ${post.latitude}, ${post.longitude}';

              await Share.share(text);
            },
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
