import 'package:e_commerce_app/common/models/notification_model.dart';

abstract class NotificationState {}

// ✅ New: idle state before user is authenticated
class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> list;
  NotificationLoaded(this.list);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}