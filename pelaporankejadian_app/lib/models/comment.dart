import 'package:cloud_firestore/cloud_firestore.dart';

class PostComment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory PostComment.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return PostComment(
      id: snapshot.id,
      userId: data?['userId'] as String? ?? '',
      userName: data?['userName'] as String? ?? 'Pengguna',
      text: data?['text'] as String? ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
