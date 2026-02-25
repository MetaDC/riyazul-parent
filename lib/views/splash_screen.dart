import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:riyazul_parent/shared/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Wait for splash to be visible
    await Future.delayed(const Duration(seconds: 2));

    final auth = Get.find<ParentAuthController>();

    // Try auto-login with saved credentials
    await auth.tryAutoLogin();

    // If auto-login loaded a student, go to dashboard; otherwise login
    if (auth.currentStudent != null) {
      Get.offNamed(AppRoutes.dashboard);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffFFF2CD),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 400,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/spalsh1.png"),
                ),
              ),
            ),
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/spalsh2.png"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
