import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/shared/routes.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'notices_channel';
  static const String channelName = 'School Notices';

  Future<NotificationService> init() async {
    await _setupLocalNotifications();
    await _setupFCM();
    return this;
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!) as Map<String, dynamic>;
            _handleMessageData(data);
          } catch (e) {
            _handleMessageData({'noticeId': details.payload});
          }
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: 'Notifications for school notices',
            importance: Importance.max,
          ),
        );
  }

  Future<void> _setupFCM() async {
    // Permission
    await _fcm.requestPermission();

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        _handleMessageData(message.data);
      }
    });

    // Check if app was opened from terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      _handleMessageData(initialMessage.data);
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final title =
        message.notification?.title ??
        message.data['title'] ??
        'School Notification';
    final body =
        message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';

    _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Notifications for school notices',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageData(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'fee') {
      Get.offAllNamed(AppRoutes.dashboard, arguments: {'tab': 2});
    } else if (type == 'result') {
      Get.offAllNamed(AppRoutes.dashboard, arguments: {'tab': 1});
    } else if (type == 'sabak' || type == 'complaint') {
      Get.offAllNamed(AppRoutes.dashboard, arguments: {'tab': 0});
    } else {
      final noticeId = data['noticeId'];
      if (noticeId != null) {
        Get.toNamed(AppRoutes.noticeDetail, arguments: noticeId);
      } else {
        // Fallback to notice list / dashboard activity tab
        Get.offAllNamed(AppRoutes.dashboard, arguments: {'tab': 3});
      }
    }
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }
}
