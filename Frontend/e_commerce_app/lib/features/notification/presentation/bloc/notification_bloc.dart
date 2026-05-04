import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/features/notification/data/notification_repository.dart';
import 'package:e_commerce_app/features/notification/presentation/bloc/notification_event.dart';
import 'package:e_commerce_app/features/notification/presentation/bloc/notification_state.dart';
import 'package:flutter/foundation.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repo;

  NotificationBloc(this.repo) : super(NotificationInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final data = await repo.getNotifications();
        emit(NotificationLoaded(data));
      } catch (e) {
        debugPrint("NotificationBloc error: $e");
        // ✅ Emit error but do NOT rethrow — a failed notification load
        // must never crash the whole app on startup
        emit(NotificationError(e.toString()));
      }
    });

    on<MarkAsRead>((event, emit) async {
      try {
        await repo.markRead(event.id);
        add(LoadNotifications());
      } catch (e) {
        debugPrint("MarkAsRead error: $e");
      }
    });
  }
}