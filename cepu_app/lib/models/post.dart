
class Post {
  final String id;
  final String image;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String userId;
  final String userFullname;

  Post({
    required this.id,
    required this.image,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.userFullname,
  });

  // Convert Firestore document to Post object
  factory Post.fromMap(Map<String, dynamic> map, String docId) {
    return Post(
      id: docId,
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      userId: map['userId'] ?? '',
      userFullname: map['userFullname'] ?? '',
    );
  }

  // Convert Post object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'userFullname': userFullname,
    };
  }
}