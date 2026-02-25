import 'package:get/get.dart';
import 'package:riyazul_parent/views/splash_screen.dart';
import 'package:riyazul_parent/views/login_screen.dart';
import 'package:riyazul_parent/views/dashboard_screen.dart';
import 'package:riyazul_parent/views/notices/notice_detail_screen.dart';
import 'package:riyazul_parent/views/notices/notice_list_screen.dart';
import 'package:riyazul_parent/views/shared/pdf_viewer_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String noticeList = '/noticeList';
  static const String noticeDetail = '/noticeDetail';
  static const String pdfViewer = '/pdfViewer';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: noticeList, page: () => const NoticeListScreen()),
    GetPage(name: noticeDetail, page: () => const NoticeDetailScreen()),
    GetPage(name: pdfViewer, page: () => const PDFViewerScreen()),
  ];
}
