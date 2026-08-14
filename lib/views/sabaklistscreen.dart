import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:riyazul_parent/models/studentnotemodel.dart';
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

    return Obx(() {
      final String deeniyatName =
          controller.deeniyatClassName.value.toLowerCase();
      final String deeniyatId =
          (controller.currentStudent?.currentDeeniyat ?? '').toLowerCase();
      final bool isHifz =
          deeniyatName.contains('hifz') || deeniyatId.contains('hifz');

      if (isHifz) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: kBg,

            // ── AppBar for Hifz (with Tabs) ──────────────────────────────────
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
                          color: Colors.white.withValues(alpha: 0.05),
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
                          color: Colors.white.withValues(alpha: 0.03),
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
                    color: Colors.white.withValues(alpha: 0.15),
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
                'Quran & Sabak Records',
                style: TextStyle(
                  color: kCream,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              bottom: const TabBar(
                indicatorColor: kCream,
                indicatorWeight: 3,
                labelColor: kCream,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.auto_stories_rounded, size: 20),
                    text: 'Quran Records',
                  ),
                  Tab(
                    icon: Icon(Icons.menu_book_outlined, size: 20),
                    text: 'Sabak Records',
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────────
            body: TabBarView(
              children: [
                _buildQuranRecordsTab(controller),
                _buildSabakRecordsTab(controller),
              ],
            ),
          ),
        );
      }

      // Non-Hifz Class -> Only show Sabak Records
      return Scaffold(
        backgroundColor: kBg,
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
                      color: Colors.white.withValues(alpha: 0.05),
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
                      color: Colors.white.withValues(alpha: 0.03),
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
                color: Colors.white.withValues(alpha: 0.15),
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
        body: _buildSabakRecordsTab(controller),
      );
    });
  }

  // ── Quran Records Tab ───────────────────────────────────────────────────
  Widget _buildQuranRecordsTab(ParentAuthController controller) {
    return Obx(() {
      if (controller.studentNotesList.isEmpty) {
        return _buildEmptyState(
          icon: Icons.auto_stories_outlined,
          title: 'No Quran records found',
          subtitle:
              'Quran progress entries will appear here once added by admin.',
        );
      }

      return Column(
        children: [
          _SubtitleBar(
            count: controller.studentNotesList.length,
            label: 'Quran',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: controller.studentNotesList.length,
              itemBuilder: (context, index) {
                final note = controller.studentNotesList[index];
                return _QuranCard(note: note, index: index);
              },
            ),
          ),
        ],
      );
    });
  }

  // ── Sabak Records Tab ───────────────────────────────────────────────────
  Widget _buildSabakRecordsTab(ParentAuthController controller) {
    return Obx(() {
      if (controller.sabakList.isEmpty) {
        return _buildEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No Sabak records found',
          subtitle: 'Sabak entries will appear here once added.',
        );
      }

      return Column(
        children: [
          _SubtitleBar(count: controller.sabakList.length, label: 'Sabak'),
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
    });
  }

  // ── Reusable Empty State Widget ──────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: kNavy.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 42, color: kNavy.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: kNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Subtitle bar ────────────────────────────────────────────────────────────
class _SubtitleBar extends StatelessWidget {
  final int count;
  final String label;
  const _SubtitleBar({required this.count, required this.label});

  static const Color kNavy = SabakListScreen.kNavy;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                TextSpan(text: '  $label records found'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quran Card Widget ───────────────────────────────────────────────────────
class _QuranCard extends StatelessWidget {
  final StudentNoteModel note;
  final int index;

  const _QuranCard({required this.note, required this.index});

  static const Color kNavy = SabakListScreen.kNavy;
  static const Color kNavyLight = SabakListScreen.kNavyLight;
  static const Color kCream = SabakListScreen.kCream;
  static const Color kBg = SabakListScreen.kBg;

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              color: kNavy.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kNavy, kNavyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: kCream,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.para.isNotEmpty
                              ? note.para
                              : 'Quran Progress Note',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: kNavy,
                            height: 1.35,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kNavy.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(note.date),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (note.remarks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffe8eaf2)),
                      ),
                      child: Text(
                        note.remarks,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xff4b5280),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (note.imageUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showImageDialog(context, note.imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Image.network(
                              note.imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
              color: kNavy.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kNavy.withValues(alpha: 0.025),
                          kCream.withValues(alpha: 0.30),
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
                      style: TextStyle(
                        fontSize: arabic ? 15 : 13.5,
                        color: const Color(0xff4b5280),
                        height: arabic ? 1.9 : 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kNavy.withValues(alpha: 0.07),
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
