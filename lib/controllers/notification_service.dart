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
          _handleMessage(details.payload!);
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
      if (message.data['noticeId'] != null) {
        _handleMessage(message.data['noticeId']);
      }
    });

    // Check if app was opened from terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null && initialMessage.data['noticeId'] != null) {
      _handleMessage(initialMessage.data['noticeId']);
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Notifications for school notices',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: message.data['noticeId'],
    );
  }

  void _handleMessage(String noticeId) {
    // Navigate to notice detail
    Get.toNamed(AppRoutes.noticeDetail, arguments: noticeId);
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }
}
