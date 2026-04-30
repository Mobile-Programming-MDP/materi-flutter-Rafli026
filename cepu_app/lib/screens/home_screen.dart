import 'package:cepu_app/models/post.dart';
import 'package:cepu_app/screens/detail_screen.dart';
import 'package:cepu_app/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cepu_app/firebase_options.dart';
import 'package:cepu_app/screens/add_post_screen.dart';
import 'package:cepu_app/services/post_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostServices _postServices = PostServices();
  late Future<List<Post>> _postsFuture;

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }

  Future<String?> getTokenAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken(true);
      return idToken;
    }

    return null;
  }

  String? _idToken = "";
  String? _uid = "";
  String? _email = "";

  Future<void> getFirebaseAuthUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _uid = user.uid;
      _email = user.email;
      await user
          .getIdToken(true)
          .then(
            (value) => {
              setState(() {
                _idToken = value;
              }),
            },
          );
    }
  }

  String generateAvatarUrl(String? fullname) {
    final safeName = (fullname == null || fullname.isEmpty) ? 'User' : fullname;
    final formattedName = safeName.trim().replaceAll(' ', '+');
    return 'https://ui-avatars.com/api/?name=$formattedName&color=7F9CF5&background=EBF4FF';
  }

  @override
  void initState() {
    super.initState();
    getFirebaseAuthUser();
    _postsFuture = loadPosts();
  }

  Future<List<Post>> loadPosts() async {
    return _postServices.getAllPosts();
  }

  String _shorten(String? value, int maxLength) {
    if (value == null || value.isEmpty) return '';
    return value.length <= maxLength ? value : '${value.substring(0, maxLength)}...';
  }

  Widget _buildPostCard(Post post) {
    final bool isDataUrl = post.image.startsWith('data:image/');
    final Widget imageWidget = isDataUrl
        ? Image.memory(
            UriData.parse(post.image).contentAsBytes(),
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
          )
        : Image.network(
            post.image,
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 140,
                color: Colors.grey[300],
                child: const Center(child: Text('Image not available')),
              );
            },
          );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPostScreen(post: post)),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget,
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(post.description),
                  const SizedBox(height: 8),
                  Text('By ${post.userFullname}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading posts: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    generateAvatarUrl(
                      FirebaseAuth.instance.currentUser?.displayName,
                    ),
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(child: Text('hellow')),
                const SizedBox(height: 8),
                Text('UID: ${_shorten(_uid, 12)}'),
                const SizedBox(height: 4),
                Text('Email: $_email'),
                const SizedBox(height: 4),
                Text('Token: ${_shorten(_idToken, 40)}'),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (posts.isEmpty)
                  const Text('Belum ada post. Tekan tombol + untuk menambahkan post.')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildPostCard(posts[index]),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          ).then((_) {
            setState(() {
              _postsFuture = loadPosts();
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
