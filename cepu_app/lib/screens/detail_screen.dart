
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cepu_app/models/post.dart';

class DetailPostScreen extends StatelessWidget {
  final Post post;

  const DetailPostScreen({super.key, required this.post});

  Future<void> _openMap() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${post.latitude},${post.longitude}';
    
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.image.startsWith('data:image/'))
              Image.memory(
                UriData.parse(post.image).contentAsBytes(),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Image not available')),
                  );
                },
              )
            else
              Image.network(
                post.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Image not available')),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userFullname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(post.category),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Latitude: ${post.latitude}'),
                  Text('Longitude: ${post.longitude}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _openMap,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Open in Maps'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}