import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riyazul_parent/controllers/notice_controller.dart';
import 'package:riyazul_parent/models/notice_model.dart';
import 'package:riyazul_parent/shared/routes.dart';

class NoticeDetailScreen extends StatelessWidget {
  const NoticeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String noticeId = Get.arguments as String;
    final controller = Get.find<NoticeController>();

    final notice = controller.notices.firstWhere(
      (n) => n.docId == noticeId,
      orElse: () => NoticeModel(
        docId: '',
        title: 'Not Found',
        body: 'This notice could not be found.',
        targetType: 'all',
        createdAt: DateTime.now(),
        createdBy: '',
      ),
    );

    final dateStr = DateFormat(
      'dd MMMM yyyy, hh:mm a',
    ).format(notice.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notice Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2C326F),
          ),
        ),
        backgroundColor: const Color(0xffFFF2CD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff2C326F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Divider(height: 32, thickness: 1),
            Text(
              notice.body,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2C326F),
                      foregroundColor: const Color(0xffFFF2CD),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () =>
                        Get.toNamed(AppRoutes.pdfViewer, arguments: notice),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff2C326F),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xff2C326F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.downloadNoticeAsPDF(notice),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
