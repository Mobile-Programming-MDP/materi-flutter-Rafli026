import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../state/app_state.dart';
import 'map_screen.dart';

class DetailPostScreen extends StatefulWidget {
  static const route = '/detail';

  final String postId;

  const DetailPostScreen({super.key, required this.postId});

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment(AppState appState) async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    setState(() {
      _isSending = true;
    });
    try {
      await appState.addComment(postId: widget.postId, text: commentText);
      _commentController.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final ReportPost post = appState.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => appState.posts.first,
    );

    final isOwner = appState.currentUser?.id == post.userId;
    final currentUserId = appState.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: Text(post.category)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          final document = snapshot.data;
          final docData = document?.data();
          final likes = docData != null
              ? _parseStringList(docData['likes'])
              : post.likes;
          final favorites = docData != null
              ? _parseStringList(docData['favorites'])
              : post.favorites;
          final isLiked =
              currentUserId != null && likes.contains(currentUserId);
          final isFavorited =
              currentUserId != null && favorites.contains(currentUserId);

          return ListView(
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
                ),

              const SizedBox(height: 16),
              Text(
                post.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? Colors.blue : null,
                  ),
                  const SizedBox(width: 8),
                  Text('${likes.length}'),
                  const SizedBox(width: 20),
                  Icon(
                    isFavorited ? Icons.star : Icons.star_border,
                    color: isFavorited ? Colors.amber : null,
                  ),
                  const SizedBox(width: 8),
                  Text('${favorites.length}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Waktu: ${post.createdAt.toLocal()}'.split('.').first,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Lokasi: ${post.latitude.toStringAsFixed(5)}, ${post.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
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
                    label: const Text('Lihat Lokasi'),
                  ),
                  ElevatedButton.icon(
                    onPressed: currentUserId == null
                        ? null
                        : () => appState.toggleLike(widget.postId),
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    ),
                    label: Text(isLiked ? 'Unlike' : 'Like'),
                  ),
                  ElevatedButton.icon(
                    onPressed: currentUserId == null
                        ? null
                        : () => appState.toggleFavorite(widget.postId),
                    icon: Icon(isFavorited ? Icons.star : Icons.star_border),
                    label: Text(isFavorited ? 'Hapus Favorit' : 'Favorit'),
                  ),
                ],
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
                      'Laporan ${post.category}\n'
                      '${post.description}\n'
                      'Lokasi: ${post.latitude}, ${post.longitude}';
                  await Share.share(text);
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Komentar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, commentSnapshot) {
                  if (commentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final comments =
                      commentSnapshot.data?.docs
                          .map((doc) => PostComment.fromSnapshot(doc))
                          .toList() ??
                      [];

                  if (comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Belum ada komentar.'),
                    );
                  }

                  return Column(
                    children: comments.map((comment) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.userName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(comment.text),
                            const SizedBox(height: 4),
                            Text(
                              comment.createdAt
                                  .toLocal()
                                  .toString()
                                  .split('.')
                                  .first,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: _isSending
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    onPressed: _isSending ? null : () => _sendComment(appState),
                  ),
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }
}
