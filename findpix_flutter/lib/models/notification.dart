class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime time;

  AppNotification({
    required this.title,
    required this.id,
    required this.description,
    required this.time,
  });

  AppNotification.fromMap(Map<String, dynamic> data)
      : title = data['title'] ?? "nil",
        description = data['description'] ?? "nil",
        id = data['id'] ?? "nil",
        time = data['time'] != null ? data['time'].toDate() : DateTime.now();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
    };
    return map;
  }
}
