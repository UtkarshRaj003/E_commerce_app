class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['isRead'],
    );
  }
}