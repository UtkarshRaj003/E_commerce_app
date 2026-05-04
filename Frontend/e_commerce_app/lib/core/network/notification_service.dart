import 'package:e_commerce_app/core/constants/api_constants.dart';
import 'package:e_commerce_app/core/network/dio_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static late GlobalKey<NavigatorState> navigatorKey;

  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ✅ Store the pending message from terminated state
  static RemoteMessage? _pendingMessage;

  static Future<void> init(GlobalKey<NavigatorState> key) async {
    if (_initialized) return;
    _initialized = true;

    navigatorKey = key;

    await _fcm.requestPermission();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        _handleNavigation(null, payload: details.payload);
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      _showLocal(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Background tap — navigator is ready, navigate immediately
      _handleNavigation(message);
    });

    // ✅ Terminated tap — DO NOT navigate here.
    // Just store it. Navigation happens after auth via consumePendingMessage().
    final RemoteMessage? initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _pendingMessage = initial;
    }
  }

  /// Call this from AuthAuthenticated state to handle terminated-state tap.
  static void consumePendingMessage() {
    if (_pendingMessage != null) {
      final msg = _pendingMessage!;
      _pendingMessage = null;
      // Small delay so MainScreen finishes building before we push on top
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleNavigation(msg);
      });
    }
  }

  static Future<void> saveFcmToken(DioClient dioClient) async {
    try {
      final token = await _fcm.getToken();
      debugPrint("FCM TOKEN: $token");
      if (token != null) {
        await dioClient.post(ApiConstants.saveToken, data: {"token": token});
      }
    } catch (e) {
      debugPrint("FCM token save error: $e");
    }
  }

  static Future<void> _showLocal(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'App notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _local.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(android: androidDetails),
      payload: message.data['type'],
    );
  }

  static void _handleNavigation(RemoteMessage? message, {String? payload}) {
    final type = message?.data['type'] ?? payload;
    debugPrint("NOTIFICATION TAP TYPE: $type");

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint("Navigator not ready — skipping");
      return;
    }

    switch (type) {
      case 'order':
        navigator.pushNamed('/orders');
        break;
      case 'cart':
        navigator.pushNamed('/cart');
        break;
      case 'wishlist':
        navigator.pushNamed('/wishlist');
        break;
      default:
        navigator.pushNamed('/notifications');
    }
  }
}