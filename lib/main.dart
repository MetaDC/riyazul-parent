import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/controllers/notification_service.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:riyazul_parent/firebase_options.dart';
import 'package:riyazul_parent/shared/routes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Handle background message if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize Notification Service in background so it doesn't block runApp
  Get.putAsync(() => NotificationService().init(), permanent: true);

  runApp(const ParentApp());
}

class ParentApp extends StatefulWidget {
  const ParentApp({super.key});

  @override
  State<ParentApp> createState() => _ParentAppState();
}

class _ParentAppState extends State<ParentApp> {
  @override
  void initState() {
    super.initState();
    // Get.put(Homectrl());
    Get.put(ParentAuthController());
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Parent App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffFFF2CD), // Light Yellow
          primary: const Color(0xffFFF2CD),
          surface: const Color(0xffF5F5F5), // Light Grey
        ),
        scaffoldBackgroundColor: const Color(0xffF5F5F5),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
