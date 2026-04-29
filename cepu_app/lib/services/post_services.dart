import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cepu_app/models/post.dart';

class PostServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new post
  Future<void> addPost(Post post) async {
    try {
      await _firestore.collection('posts').add(post.toMap());
    } catch (e) {
      throw Exception('Error adding post: $e');
    }
  }

  // Get all posts
  Future<List<Post>> getAllPosts() async {
    try {
      final querySnapshot = await _firestore.collection('posts').get();
      return querySnapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error getting posts: $e');
    }
  }

  // Get post by ID
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return Post.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting post: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  // Update post
  Future<void> updatePost(String postId, Post post) async {
    try {
      await _firestore.collection('posts').doc(postId).update(post.toMap());
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }
}