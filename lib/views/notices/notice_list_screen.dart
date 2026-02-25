import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riyazul_parent/controllers/notice_controller.dart';
import 'package:riyazul_parent/shared/routes.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoticeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notices',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2C326F),
          ),
        ),
        backgroundColor: const Color(0xffFFF2CD),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.notices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notices yet.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notices.length,
          itemBuilder: (context, index) {
            final notice = controller.notices[index];
            final dateStr = DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(notice.createdAt);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  notice.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xff2C326F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      notice.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xff2C326F),
                ),
                onTap: () => Get.toNamed(
                  AppRoutes.noticeDetail,
                  arguments: notice.docId,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
