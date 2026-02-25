import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:riyazul_parent/controllers/notice_controller.dart';
import 'package:riyazul_parent/shared/routes.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color kNavy = Color(0xff2C326F);
  static const Color kNavyLight = Color(0xff3D4494);
  static const Color kNavyDark = Color(0xff1E2252);
  static const Color kCream = Color(0xffFFF2CD);
  static const Color kCreamDark = Color(0xffF5E6A3);

  @override
  Widget build(BuildContext context) {
    final ParentAuthController authController =
        Get.find<ParentAuthController>();
    Get.put(NoticeController());
    final student = authController.currentStudent;

    if (student == null) {
      return Scaffold(
        backgroundColor: kNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: kCream, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Session expired',
                style: TextStyle(color: kCream, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCream,
                  foregroundColor: kNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4, // ✅ 4 tabs
      child: Scaffold(
        backgroundColor: const Color(0xffF4F6FB),

        // ── Fixed Top AppBar ─────────────────────────────────────────────
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
                  bottom: 10,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kCream.withOpacity(0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kCream,
                  image: const DecorationImage(
                    image: AssetImage("assets/images/riyazul.png"),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: kCreamDark, width: 2),
                ),
                // child: const Icon(Icons.person, size: 22, color: kNavy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "JAMIAH RIYAZUL ULOOM",
                      // student.name,
                      // maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kCream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    // Text(
                    //   'GR No: ${student.grNO}',
                    //   style: TextStyle(
                    //     color: kCream.withOpacity(0.7),
                    //     fontSize: 11,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.noticeList),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: kCream,
                    size: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => authController.confirmLogout(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout, color: kCream, size: 20),
                ),
              ),
            ),
          ],
        ),

        // ── Tab Content — 4 children matching 4 tabs ─────────────────────
        body: TabBarView(
          children: [
            _buildProfileSection(student),
            _buildResultsSection(authController),
            _buildFeesSection(authController),
            _buildActivitySection(authController), // ✅ fixed: was missing
          ],
        ),

        // ── Bottom TabBar ────────────────────────────────────────────────
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: kNavy,
            boxShadow: [
              BoxShadow(
                color: kNavy.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kNavyDark, kNavyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: TabBar(
                indicatorColor: kCream,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: kCream,
                unselectedLabelColor: Colors.white38,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
                // ✅ Fixed: removed const from tabs list so Obx works
                tabs: [
                  const Tab(
                    icon: Icon(Icons.person_outline, size: 22),
                    text: 'Profile',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  const Tab(
                    icon: Icon(Icons.grading_outlined, size: 22),
                    text: 'Results',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  const Tab(
                    icon: Icon(Icons.receipt_long_outlined, size: 22),
                    text: 'Fees',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  // ✅ Fixed: Obx cannot be inside const — removed const
                  Tab(
                    iconMargin: const EdgeInsets.only(bottom: 2),
                    text: 'Activity',
                    icon: Obx(() {
                      final count =
                          Get.find<ParentAuthController>().unreadCount.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_outlined, size: 22),
                          if (count > 0)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── ACTIVITY SECTION ──────────────────────────────────────────────────────
  Widget _buildActivitySection(ParentAuthController controller) {
    return Obx(() {
      if (controller.notifications.isEmpty) {
        return _buildEmptyState(
          icon: Icons.notifications_none_outlined,
          message: 'No activity yet.',
        );
      }
      return Column(
        children: [
          if (controller.unreadCount.value > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => controller.markAllAsRead(
                    controller.currentStudent!.docId,
                  ),
                  child: Text(
                    'Mark all as read',
                    style: TextStyle(
                      fontSize: 12,
                      color: kNavy.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notif = controller.notifications[index];
                return GestureDetector(
                  onTap: () => controller.markAsRead(notif.docId),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? Colors.white
                          : kCream.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead ? Colors.grey.shade200 : kCreamDark,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kNavy.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _notifIconBg(notif.type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _notifIcon(notif.type),
                              color: _notifIconColor(notif.type),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: notif.isRead
                                              ? FontWeight.w600
                                              : FontWeight.bold,
                                          fontSize: 14,
                                          color: kNavy,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(notif.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'result':
        return Icons.grading_outlined;
      case 'fee':
        return Icons.receipt_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _notifIconBg(String type) {
    switch (type) {
      case 'result':
        return kNavy.withOpacity(0.08);
      case 'fee':
        return const Color(0xffE8F5E9);
      default:
        return kCream.withOpacity(0.6);
    }
  }

  Color _notifIconColor(String type) {
    switch (type) {
      case 'result':
        return kNavy;
      case 'fee':
        return const Color(0xff2E7D32);
      default:
        return kNavyLight;
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  Widget _buildProfileSection(dynamic student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader('Student Information'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kNavy.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kNavy, kNavyLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: kCream,
                          shape: BoxShape.circle,
                          border: Border.all(color: kCreamDark, width: 3),
                        ),
                        child: const Icon(Icons.person, size: 44, color: kNavy),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        student.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kCream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GR No: ${student.grNO}',
                        style: TextStyle(
                          color: kCream.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Obx(
                        () => _buildInfoRow(
                          Icons.school_outlined,
                          'Class / Std',
                          Get.find<ParentAuthController>()
                                  .schoolClassName
                                  .value
                                  .isNotEmpty
                              ? Get.find<ParentAuthController>()
                                    .schoolClassName
                                    .value
                              : 'N/A',
                        ),
                      ),
                      Obx(
                        () => _buildInfoRow(
                          Icons.menu_book_outlined,
                          'Deeniyat Class',
                          Get.find<ParentAuthController>()
                                  .deeniyatClassName
                                  .value
                                  .isNotEmpty
                              ? Get.find<ParentAuthController>()
                                    .deeniyatClassName
                                    .value
                              : 'N/A',
                        ),
                      ),
                      _buildInfoRow(
                        Icons.cake_outlined,
                        'Date of Birth',
                        DateFormat('dd MMM yyyy').format(student.dob),
                      ),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Phone',
                        student.phoneNumber,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kNavy, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: kNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }

  Widget _buildResultsSection(ParentAuthController controller) {
    return Obx(() {
      if (controller.studentResults.isEmpty) {
        return _buildEmptyState(
          icon: Icons.grading_outlined,
          message: 'No results found for this student.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.studentResults.length,
        itemBuilder: (context, index) {
          final result = controller.studentResults[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Theme(
              data: ThemeData(
                dividerColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                childrenPadding: EdgeInsets.zero,
                leading: Container(
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
                  child: const Icon(Icons.grading, color: kCream, size: 22),
                ),
                title: Text(
                  result.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kNavy,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildSmallChip(
                        result.academicYear,
                        Icons.calendar_today_outlined,
                      ),
                      _buildSmallChip(result.className, Icons.school_outlined),
                      if (result.presentDays.isNotEmpty)
                        _buildSmallChip(
                          'Present: ${result.presentDays}',
                          Icons.event_available_outlined,
                        ),
                    ],
                  ),
                ),
                iconColor: kNavy,
                collapsedIconColor: kNavy,
                children: [
                  if (result.remarks.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kCream.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kCreamDark, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_outlined,
                            size: 14,
                            color: kNavy.withOpacity(0.55),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              result.remarks,
                              style: TextStyle(
                                fontSize: 12,
                                color: kNavy.withOpacity(0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: kNavy.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'Subject',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kNavy,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        _buildMarkHeader('Marks'),
                        _buildMarkHeader('Sem 1'),
                        _buildMarkHeader('Sem 2'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...result.subjects.asMap().entries.map((entry) {
                    final sub = entry.value;
                    final isLast = entry.key == result.subjects.length - 1;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              sub.subName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (sub.isOptional) ...[
                                            const SizedBox(width: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Opt',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (sub.gRemarks.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            sub.gRemarks,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                _buildMarkCell(sub.subMarks, isTotal: true),
                                _buildMarkCell(sub.sem1Marks),
                                _buildMarkCell(sub.sem2Marks),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(height: 1, color: Colors.grey.shade100),
                        ],
                      ),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: kNavy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Marks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kNavy,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          result.totalMarks,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kNavy,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMarkHeader(String label) {
    return SizedBox(
      width: 48,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kNavy,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildMarkCell(String value, {bool isTotal = false}) {
    return SizedBox(
      width: 48,
      child: Center(
        child: isTotal
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kNavy.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value.isEmpty ? '-' : value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kNavy,
                  ),
                ),
              )
            : Text(
                value.isEmpty ? '-' : value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildFeesSection(ParentAuthController controller) {
    return Obx(() {
      if (controller.studentFees.isEmpty) {
        return _buildEmptyState(
          icon: Icons.receipt_long_outlined,
          message: 'No fee records found for this student.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: controller.studentFees.length,
        itemBuilder: (context, index) {
          final feeTx = controller.studentFees[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Theme(
              data: ThemeData(
                dividerColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                childrenPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xffE8F5E9),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.receipt_rounded,
                    color: Color(0xff2E7D32),
                    size: 24,
                  ),
                ),
                title: Text(
                  'Receipt #${feeTx.receiptNo.isNotEmpty ? feeTx.receiptNo : "N/A"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kNavy,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildSmallChip(
                        feeTx.feeDetails[0]['type'],
                        Icons.category_outlined,
                      ),
                      _buildSmallChip(
                        feeTx.paymentMode,
                        Icons.credit_card_outlined,
                      ),
                      _buildSmallChip(
                        feeTx.acedemicYear,
                        Icons.school_outlined,
                      ),
                    ],
                  ),
                ),
                iconColor: kNavy,
                collapsedIconColor: kNavy,
                children: [
                  const Divider(height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTwoColRow(
                          _buildFeeDetailCell(
                            'Period From',
                            DateFormat('MMM yyyy').format(feeTx.startDate),
                            Icons.calendar_today_outlined,
                          ),
                          _buildFeeDetailCell(
                            'Period To',
                            DateFormat('MMM yyyy').format(feeTx.endDate),
                            Icons.event_outlined,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTwoColRow(
                          _buildFeeDetailCell(
                            'Received On',
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(feeTx.receivedDate),
                            Icons.today_outlined,
                          ),
                          _buildFeeDetailCell(
                            'Total Amount',
                            'Rs.${feeTx.totalAmt}',
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        if (feeTx.feeDetails.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: kNavy.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt_outlined,
                                      size: 13,
                                      color: kNavy.withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'FEE BREAKDOWN',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: kNavy.withOpacity(0.55),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...feeTx.feeDetails.asMap().entries.map((e) {
                                  final detail = e.value;
                                  final isLast =
                                      e.key == feeTx.feeDetails.length - 1;
                                  final name =
                                      detail['type']?.toString() ??
                                      detail['feeName']?.toString() ??
                                      '';
                                  final amt =
                                      detail['amount']?.toString() ??
                                      detail['amt']?.toString() ??
                                      '';
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Rs.$amt',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: kNavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!isLast) ...[
                                        const SizedBox(height: 8),
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ],
                                  );
                                }),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(height: 1),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Received',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xff2E7D32),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.find<NoticeController>()
                                          .downloadFeeReceipt(feeTx),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kNavy.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.download,
                                              size: 14,
                                              color: kNavy,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Receipt',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: kNavy,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (feeTx.remarks.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kCream.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kCreamDark, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notes_outlined,
                                  size: 15,
                                  color: kNavy.withOpacity(0.55),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feeTx.remarks,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kNavy.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ],
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
        },
      );
    });
  }

  Widget _buildTwoColRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        Container(width: 1, height: 36, color: const Color(0xffEEEEEE)),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildFeeDetailCell(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: kNavy.withOpacity(0.4)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kNavy.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: kNavy.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: kNavy,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kNavy.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: kNavy.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: kNavy.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
