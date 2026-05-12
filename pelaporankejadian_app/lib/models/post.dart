import 'dart:typed_data';

class ReportPost {
  final String id;
  final String userId;
  final String userName;
  final String category;
  final String description;
  final DateTime createdAt;

  /// Local file path (untuk versi in-memory)
  final String? imagePath;

  /// Gambar disimpan sebagai bytes agar Web dan mobile keduanya didukung.
  final Uint8List? imageBytes;

  // Simpan lat/lng sebagai double agar tidak bergantung ke latlong2 untuk compile.
  final double latitude;
  final double longitude;

  const ReportPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    this.imageBytes,
  });
}
