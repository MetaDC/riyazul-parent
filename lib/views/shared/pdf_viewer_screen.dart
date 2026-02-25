import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/models/notice_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:riyazul_parent/controllers/notice_controller.dart';

class PDFViewerScreen extends StatelessWidget {
  const PDFViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can handle both NoticeModel and potentially other models or raw bytes
    final dynamic argument = Get.arguments;
    final controller = Get.find<NoticeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          argument is NoticeModel ? argument.title : 'PDF Viewer',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2C326F),
          ),
        ),
        backgroundColor: const Color(0xffFFF2CD),
        elevation: 0,
        actions: [
          if (argument is NoticeModel)
            IconButton(
              icon: const Icon(Icons.download, color: Color(0xff2C326F)),
              onPressed: () => controller.downloadNoticeAsPDF(argument),
            ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: argument is NoticeModel
            ? controller.generatePDF(argument).then((value) => value.toList())
            : Future.value(argument as List<int>),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No PDF data found.'));
          }

          return SfPdfViewer.memory(snapshot.data as dynamic);
        },
      ),
    );
  }
}
