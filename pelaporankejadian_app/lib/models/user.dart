class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoBase64;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoBase64,
  });

  AppUser copyWith({String? name, String? email, String? photoBase64}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}
