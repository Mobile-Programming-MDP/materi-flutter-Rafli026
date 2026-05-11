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
          if (post.imageBytes != null && post.imageBytes!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                post.imageBytes!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            const SizedBox.shrink(),

          const SizedBox(height: 14),
          Text(post.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          Text(
            'Waktu: ${post.createdAt.toLocal()}'.split('.').first,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Lokasi: ${post.latitude.toStringAsFixed(5)}, ${post.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: MapScreen(
              initialLat: post.latitude,
              initialLng: post.longitude,
              title: post.category,
            ),
          ),

          const SizedBox(height: 16),
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

          ElevatedButton.icon(
            onPressed: () async {
              final text =
                  'Laporan ${post.category}\n${post.description}\nLokasi: ${post.latitude}, ${post.longitude}';
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
