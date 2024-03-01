class AppUser {
  final String id;
  final String fullName;
  final String photoUrl;
  final String email;
  final double latitude;
  final double longitude;
  final DateTime regTime;

  AppUser({
    required this.id,
    required this.fullName,
    required this.photoUrl,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.regTime,
  });

  AppUser.fromMap(Map<String, dynamic> data)
      : id = data['id'] ?? "",
        fullName = data['fullName'] ?? "nil",
        photoUrl = data['photoUrl'] ?? "nil",
        email = data['email'] ?? "nil",
        latitude = data['lat'] ?? 0.0,
        longitude = data['long'] ?? 0.0,
        regTime =
            data['regTime'] != null ? data['regTime'].toDate() : DateTime.now();

  Map<String, dynamic> toJson(keyword) {
    Map<String, dynamic> map = {
      'id': id,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'keyword': keyword,
      'email': email,
      'lat': latitude,
      'long': longitude,
      'regTime': regTime,
    };
    // if (imgString != null) map['imgString'] = imgString!;
    return map;
  }

  AppUser copyWith({
    String? id,
    String? fullName,
    String? photoUrl,
    String? email,
    String? userRole,
    double? latitude,
    double? longitude,
    String? place,
    DateTime? regTime,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      regTime: regTime ?? this.regTime,
    );
  }
}
