import 'package:cepu_app/models/post.dart';
import 'package:cepu_app/screens/map_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DetailPostScreen extends StatelessWidget {
  final Post post;

  const DetailPostScreen({super.key, required this.post});

  String generateAvatarUrl(String? fullname) {
    final safeName = (fullname == null || fullname.isEmpty) ? 'User' : fullname;
    final formattedName = safeName.trim().replaceAll(' ', '+');
    return 'https://ui-avatars.com/api/?name=$formattedName&color=7F9CF5&background=EBF4FF';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDataUrl = post.image.startsWith('data:image/');

    final Widget imageWidget = isDataUrl
        ? Image.memory(
            UriData.parse(post.image).contentAsBytes(),
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          )
        : Image.network(
            post.image,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: Text('Image not available')),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Post'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget,
            const SizedBox(height: 16),
            Text(
              post.category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.network(
                generateAvatarUrl(post.userFullname),
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'By ${post.userFullname}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lokasi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Latitude: ${post.latitude}'),
            Text('Longitude: ${post.longitude}'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final String shareText = '''
Post dari ${post.userFullname}

Kategori: ${post.category}

${post.description}

Lokasi: ${post.latitude}, ${post.longitude}
''';
                    await Share.share(
                      shareText,
                      subject: 'Cek post ini dari Cepu App!',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapDetailScreen(post: post),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Lihat Map'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}