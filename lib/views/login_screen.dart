import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _grNoController = TextEditingController();
  final _grFocusNode = FocusNode();
  DateTime? _selectedDate;
  final ParentAuthController _authController = Get.find<ParentAuthController>();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color kNavy = Color(0xff2C326F);
  static const Color kCream = Color(0xffFFF2CD);
  static const Color kNavyLight = Color(0xff3D4494);
  static const Color kNavyDark = Color(0xff1E2252);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _grNoController.dispose();
    _grFocusNode.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kNavy,
              onPrimary: kCream,
              onSurface: kNavy,
              surface: kCream,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      // Normalize to UTC midnight — consistent with how DOB is stored/compared
      setState(
        () => _selectedDate = DateTime.utc(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        ),
      );
    });
  }

  void _onGrSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      // Automatically open date picker after GR is entered
      _presentDatePicker();
    }
  }

  void _submitLogin() {
    if (_grNoController.text.isEmpty || _selectedDate == null) {
      Get.snackbar(
        'Missing Information',
        'Please enter GR Number and select Date of Birth',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kNavyDark,
        colorText: kCream,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: kCream),
      );
      return;
    }
    _authController.login(_grNoController.text.trim(), _selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kNavyLight.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kNavyDark.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCream.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top header section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: kCream,
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage(
                                    "assets/images/riyazul.png",
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(height: 6),
                            const Text(
                              'Parent Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: kCream,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to track your child\'s progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: kCream.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Card section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: kCream,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Step 1: GR Number ──────────────────────────
                            _buildLabel('GR Number'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _grNoController,
                              focusNode: _grFocusNode,
                              style: const TextStyle(
                                color: kNavy,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              cursorColor: Colors.black,
                              decoration: _inputDecoration(
                                hint: 'Enter GR No. (e.g. 101)',
                                icon: Icons.badge_outlined,
                              ),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              // Auto-open date picker on done
                              onSubmitted: _onGrSubmitted,
                            ),

                            const SizedBox(height: 22),

                            // ── Step 2: Date of Birth (tap or auto-opens) ──
                            _buildLabel('Date of Birth'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _presentDatePicker,
                              borderRadius: BorderRadius.circular(14),
                              child: InputDecorator(
                                decoration: _inputDecoration(
                                  hint: 'Select Date',
                                  icon: Icons.calendar_today_outlined,
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select Date'
                                      : DateFormat(
                                          'dd MMMM yyyy',
                                        ).format(_selectedDate!),
                                  style: TextStyle(
                                    color: _selectedDate == null
                                        ? Colors.grey.shade500
                                        : kNavy,
                                    fontSize: 16,
                                    fontWeight: _selectedDate == null
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Step 3: Submit ─────────────────────────────
                            Obx(
                              () => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors: _authController.isLoading.value
                                        ? [
                                            kNavyLight.withOpacity(0.6),
                                            kNavy.withOpacity(0.6),
                                          ]
                                        : [kNavyLight, kNavyDark],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: _authController.isLoading.value
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: kNavy.withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : _submitLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 17,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _authController.isLoading.value
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: kCream,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: kCream,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: kCream,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Center(
                              child: Text(
                                'Contact Riyazul admin if you need help',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        '© Riyazul Academy',
                        style: TextStyle(
                          color: kCream.withOpacity(0.35),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: kNavy,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: kNavy.withOpacity(0.6), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kNavy, width: 1.8),
      ),
    );
  }
}
