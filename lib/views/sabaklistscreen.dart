import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:intl/intl.dart';

class SabakListScreen extends StatelessWidget {
  const SabakListScreen({super.key});

  static const Color kNavy = Color(0xff2C326F);
  static const Color kNavyLight = Color(0xff3D4494);
  static const Color kNavyDark = Color(0xff1E2252);
  static const Color kCream = Color(0xffFFF2CD);
  static const Color kCreamDark = Color(0xffF5E6A3);
  static const Color kBg = Color(0xffF4F6FB);

  @override
  Widget build(BuildContext context) {
    final ParentAuthController controller = Get.find<ParentAuthController>();

    return Scaffold(
      backgroundColor: kBg,

      // ── AppBar ────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kNavyDark, kNavyLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: 60,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: kCream,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Sabak Records',
          style: TextStyle(
            color: kCream,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────
      body: Obx(() {
        // ── Empty State ────────────────────────────────────────────────
        if (controller.sabakList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: kNavy.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 42,
                    color: kNavy.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Sabak records found',
                  style: TextStyle(
                    color: kNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sabak entries will appear here once added.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // ── List ───────────────────────────────────────────────────────
        return Column(
          children: [
            // Subtitle bar
            _SubtitleBar(count: controller.sabakList.length),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: controller.sabakList.length,
                itemBuilder: (context, index) {
                  final sabak = controller.sabakList[index];
                  return _SabakCard(sabak: sabak, index: index);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Subtitle bar ────────────────────────────────────────────────────────────
class _SubtitleBar extends StatelessWidget {
  final int count;
  const _SubtitleBar({required this.count});

  static const Color kNavy = SabakListScreen.kNavy;
  static const Color kCream = SabakListScreen.kCream;
  static const Color kCreamDark = SabakListScreen.kCreamDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Record count
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff9aa0c0),
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: '$count',
                  style: const TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const TextSpan(text: '  records found'),
              ],
            ),
          ),

          // Filter chip
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: kCream,
          //     border: Border.all(color: kCreamDark),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(
          //         Icons.tune_rounded,
          //         size: 12,
          //         color: kNavy.withOpacity(0.8),
          //       ),
          //       const SizedBox(width: 5),
          //       Text(
          //         'All Books',
          //         style: TextStyle(
          //           fontSize: 11,
          //           fontWeight: FontWeight.w600,
          //           color: kNavy.withOpacity(0.85),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ── Sabak Card ──────────────────────────────────────────────────────────────
class _SabakCard extends StatelessWidget {
  final dynamic sabak;
  final int index;

  const _SabakCard({required this.sabak, required this.index});

  static const Color kNavy = SabakListScreen.kNavy;
  static const Color kNavyLight = SabakListScreen.kNavyLight;
  static const Color kCream = SabakListScreen.kCream;
  static const Color kCreamDark = SabakListScreen.kCreamDark;

  /// Detect if string contains Arabic/Urdu characters
  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final bool arabic = _isArabic(sabak.sabakText);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffe8eaf2)),
          boxShadow: [
            BoxShadow(
              color: kNavy.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Index badge ────────────────────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kNavy, kNavyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: kCream,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book name + date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          sabak.bookName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: kNavy,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Sabak text block ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kNavy.withOpacity(0.025),
                          kCream.withOpacity(0.30),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: arabic
                            ? BorderSide.none
                            : BorderSide(color: kCreamDark, width: 3),
                        right: arabic
                            ? BorderSide(color: kCreamDark, width: 3)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      sabak.sabakText,
                      textAlign: arabic ? TextAlign.right : TextAlign.left,
                      // textDirection: arabic
                      //     // ? TextDirection.rtl
                      //     // : TextDirection.ltr,
                      style: TextStyle(
                        // fontFamily: arabic ? 'Amiri' : null,
                        fontSize: arabic ? 15 : 13.5,
                        color: const Color(0xff4b5280),
                        height: arabic ? 1.9 : 1.6,
                        // fontStyle: arabic ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),

                  // ── Para / Book chip ──────────────────────────────────
                  // Wrap(
                  //   spacing: 8,
                  //   children: [
                  //     _Chip(
                  //       icon: Icons.bookmark_outline_rounded,
                  //       label: sabak.bookName,
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kNavy.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(sabak.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable chip ──────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  static const Color kNavy = SabakListScreen.kNavy;
  static const Color kCream = SabakListScreen.kCream;
  static const Color kCreamDark = SabakListScreen.kCreamDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kCream.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCreamDark, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kNavy.withOpacity(0.7)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kNavy.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
