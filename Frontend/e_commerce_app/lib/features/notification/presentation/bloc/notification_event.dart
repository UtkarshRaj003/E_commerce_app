abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {
  final String id;
  MarkAsRead(this.id);
}