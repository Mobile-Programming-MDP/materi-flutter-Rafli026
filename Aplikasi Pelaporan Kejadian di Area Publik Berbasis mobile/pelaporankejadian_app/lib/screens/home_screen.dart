import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../models/post.dart';

import 'add_post_screen.dart';
import 'detail_post_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/home';

  final AppState appState;

  const HomeScreen(this.appState, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            onPressed: appState.toggleTheme,
            icon: Icon(
              appState.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await appState.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/signin');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final posts = appState.posts;
          if (posts.isEmpty) {
            return const Center(
              child: Text('Belum ada laporan. Silakan Add Post.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ReportPost p = posts[index];
              return _PostCard(
                post: p,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    DetailPostScreen.route,
                    arguments: {'postId': p.id},
                  );
                },
                onOpenMap: () {
                  Navigator.of(context).pushNamed(
                    MapScreen.route,
                    arguments: {
                      'lat': p.latitude,
                      'lng': p.longitude,

                      'title': p.category,
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AddPostScreen.route);
        },
        label: const Text('Add Post'),
        icon: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ReportPost post;
  final VoidCallback onTap;
  final VoidCallback onOpenMap;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.category,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${post.latitude.toStringAsFixed(4)}, ${post.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Map'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
