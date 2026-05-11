import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
    _subscribePosts();
    _onAuthChanged(_auth.currentUser);
  }

  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final StreamSubscription<User?> _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _postsSub;

  ThemeMode themeMode = ThemeMode.light;

  AppUser? currentUser;

  final List<ReportPost> _posts = [];

  List<ReportPost> get posts => List.unmodifiable(_posts);

  void _onAuthChanged(User? user) {
    currentUser = user == null
        ? null
        : AppUser(
            id: user.uid,
            name: (user.displayName?.trim().isEmpty ?? true)
                ? 'Pengguna'
                : user.displayName!.trim(),
            email: user.email ?? '',
          );

    if (currentUser == null) {
      _posts.clear();
      _postsSub?.cancel();
      _postsSub = null;
    } else {
      _resubscribePosts();
    }

    notifyListeners();
  }

  void _resubscribePosts() {
    _postsSub?.cancel();
    _subscribePosts();
  }

  void _subscribePosts() {
    if (_postsSub != null) {
      return;
    }

    print('Subscribing to posts...');
    _postsSub = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            print('Posts snapshot received: ${snapshot.docs.length} docs');
            final posts = <ReportPost>[];

            for (final doc in snapshot.docs) {
              final data = doc.data();
              print('Post doc: ${doc.id}, data keys: ${data.keys.toList()}');

              posts.add(
                ReportPost(
                  id: doc.id,
                  userId: _parseString(data['userId']),
                  userName: _parseString(data['userName']),
                  category: _parseString(data['category'], fallback: 'Lainnya'),
                  description: _parseString(data['description']),
                  createdAt:
                      _parseDateTime(data['createdAt']) ?? DateTime.now(),
                  latitude: _parseDouble(data['latitude']),
                  longitude: _parseDouble(data['longitude']),
                  imagePath: _parseNullableString(data['imagePath']),
                  imageBytes: _parseImageBytes(data['imageData']),
                ),
              );
            }

            _posts
              ..clear()
              ..addAll(posts);
            notifyListeners();
            print('Posts updated, count: ${_posts.length}');
          },
          onError: (e) {
            print('Error subscribing to posts: $e');
          },
        );
  }

  String _parseString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Uint8List? _parseImageBytes(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return base64Decode(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      _onAuthChanged(_auth.currentUser);
      return null;
    } on FirebaseAuthException catch (e) {
      print('SignUp Error Code: ${e.code}, Message: ${e.message}');
      if (e.code == 'email-already-in-use') {
        return 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        return 'Password terlalu lemah';
      } else if (e.code == 'invalid-email') {
        return 'Email tidak valid';
      }
      return 'Gagal mendaftar: ${e.message}';
    } catch (e) {
      print('SignUp Exception: $e');
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      print('SignIn Error Code: ${e.code}, Message: ${e.message}');
      if (e.code == 'user-not-found') {
        return 'Email tidak terdaftar';
      } else if (e.code == 'wrong-password') {
        return 'Password salah';
      } else if (e.code == 'invalid-email') {
        return 'Email tidak valid';
      }
      return 'Gagal login: ${e.message}';
    } catch (e) {
      print('SignIn Exception: $e');
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  Future<void> addPost({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    if (currentUser == null) throw Exception('User belum login');

    try {
      final postData = {
        'userId': currentUser!.id,
        'userName': currentUser!.name,
        'category': category.trim(),
        'description': description.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'latitude': latitude,
        'longitude': longitude,
        'imagePath': imagePath,
        if (imageBytes != null) 'imageData': base64Encode(imageBytes),
      };

      await _firestore.collection('posts').add(postData);
      print('Post berhasil disimpan');
    } catch (e) {
      print('Gagal menyimpan post: $e');
      throw Exception('Gagal menyimpan post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    if (currentUser == null) throw Exception('User belum login');

    // asumsi: user hanya boleh hapus post miliknya
    final doc = await _firestore.collection('posts').doc(postId).get();
    if (!doc.exists) return;

    final data = doc.data();
    final ownerId = data?['userId'] as String?;
    if (ownerId != currentUser!.id) {
      throw Exception('Hanya pemilik post yang bisa menghapus');
    }

    await _firestore.collection('posts').doc(postId).delete();
  }

  @override
  void dispose() {
    _authSub.cancel();
    _postsSub?.cancel();
    super.dispose();
  }
}

/// Scope sederhana untuk akses [AppState] tanpa package tambahan.
class AppStateScope extends InheritedWidget {
  final AppState appState;

  const AppStateScope({
    super.key,
    required this.appState,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.appState;
  }

  @override
  bool updateShouldNotify(covariant AppStateScope oldWidget) => true;
}
