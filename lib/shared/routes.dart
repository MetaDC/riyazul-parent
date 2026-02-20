import 'package:get/get.dart';
import 'package:riyazul_parent/views/splash_screen.dart';
import 'package:riyazul_parent/views/login_screen.dart';
import 'package:riyazul_parent/views/dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
  ];
}
