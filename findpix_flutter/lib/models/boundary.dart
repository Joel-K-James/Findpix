class Boundary {
  final String id;
  final String name;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final double boundaryMeters;
  final double currentLat;
  final double currentLong;

  Boundary({
    required this.id,
    required this.name,
    required this.startDateTime,
    required this.endDateTime,
    required this.boundaryMeters,
    required this.currentLat,
    required this.currentLong,
  });

  Boundary.fromMap(Map<String, dynamic> data)
      : id = data['id'] ?? "",
        name = data['name'] ?? "nil",
        startDateTime = data['startDateTime'] != null ? data['startDateTime'].toDate() : DateTime.now(),
        endDateTime = data['endDateTime'] != null ? data['endDateTime'].toDate() : DateTime.now(),
        boundaryMeters = data['boundaryMeters'] ?? 0.0,
        currentLat = data['currentLat'] ?? 0.0,
        currentLong = data['currentLong'] ?? 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'boundaryMeters': boundaryMeters,
      'currentLat': currentLat,
      'currentLong': currentLong,
    };
  }
}
