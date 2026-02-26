import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:riyazul_parent/controllers/parent_auth_controller.dart';
import 'package:riyazul_parent/models/notice_model.dart';
import 'package:riyazul_parent/models/feeTransactionmodel.dart';
import 'package:riyazul_parent/shared/firebase.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:riyazul_parent/shared/method.dart';
import 'package:rxdart/rxdart.dart' as rx;

class NoticeController extends GetxController {
  final ParentAuthController _authController = Get.find<ParentAuthController>();

  var notices = <NoticeModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.currentStudent != null) {
      listenToNotices();
    }
  }

  void listenToNotices() {
    final student = _authController.currentStudent!;

    // Stream for 'all' notices
    final allNoticesStream = FBFireStore.notices
        .where('targetType', isEqualTo: 'all')
        .snapshots();

    // Stream for specific notices by studentId
    final specificStudentStream = FBFireStore.notices
        .where('targetType', isEqualTo: 'specific')
        .where('studentId', isEqualTo: student.docId)
        .snapshots();

    // Stream for specific notices by grNo (handling variations)
    final grNoStream = FBFireStore.notices
        .where('targetType', isEqualTo: 'specific')
        .where('grNo', isEqualTo: student.grNO)
        .snapshots();

    // Combine streams
    rx.Rx.combineLatest3(allNoticesStream, specificStudentStream, grNoStream, (
      QuerySnapshot all,
      QuerySnapshot specificIds,
      QuerySnapshot specificGrs,
    ) {
      final List<NoticeModel> combined = [];
      final Set<String> ids = {};

      void addUnique(QuerySnapshot snap) {
        for (var doc in snap.docs) {
          if (!ids.contains(doc.id)) {
            combined.add(NoticeModel.fromSnapshot(doc));
            ids.add(doc.id);
          }
        }
      }

      addUnique(all);
      addUnique(specificIds);
      addUnique(specificGrs);

      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
    }).listen((updatedNotices) {
      notices.value = updatedNotices;
    });
  }

  Future<void> downloadNoticeAsPDF(NoticeModel notice) async {
    try {
      isLoading.value = true;

      // Check permissions
      if (Platform.isAndroid) {
        await Permission.storage.request();
        // Android 13+ needs different permissions usually handled by internal logic or specific flags,
        // but path_provider's getExternalStorageDirectory is usually safe.
      }

      final pdfBytes = await generatePDF(notice);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Notice_${notice.docId}_$timestamp.pdf';

      await _saveAndOpenPDF(pdfBytes, fileName);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to download PDF: $e');
    }
  }

  Future<void> _saveAndOpenPDF(Uint8List pdfBytes, String fileName) async {
    try {
      String dirPath;
      if (Platform.isAndroid) {
        dirPath = '/storage/emulated/0/Download';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        dirPath = dir.path;
      }

      final file = File('$dirPath/$fileName');
      await file.writeAsBytes(pdfBytes);

      Get.snackbar(
        'Success',
        'Downloaded to Downloads folder',
        snackPosition: SnackPosition.BOTTOM,
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save or open PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Uint8List> generatePDF(NoticeModel notice) async {
    final pdf = pw.Document();

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/riyazul.png')).buffer.asUint8List(),
    );
    final nameImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/spalsh1.png')).buffer.asUint8List(),
    );
    final stampImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/stamp.png')).buffer.asUint8List(),
    );
    final signImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/feeslogo.png',
      )).buffer.asUint8List(),
    );

    final dateStr = DateFormat('dd MMMM yyyy').format(notice.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
          padding: const pw.EdgeInsets.all(12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "MANAGED BY RAHMAT E AALAM CHARITABLE TRUST",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    "NO. E/7941/VADODARA",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Center(
                      child: pw.Text(
                        "JAMIAH RIYAZUL ULOOM (BARODA)",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Image(logoImage, width: 50, height: 50),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Image(
                      nameImage,
                      height: 40,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "KADU NI PAGA, MACHCHIPITH, VADODARA-01",
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      "9104024313 / 9898610513",
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 25),

              // Title
              pw.Center(
                child: pw.Text(
                  notice.title.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Date: $dateStr",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 30),

              // Body
              pw.Expanded(
                child: pw.Text(
                  notice.body,
                  style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Principal's Sign:",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Image(signImage, width: 60, height: 60),
                      // Placeholder for sign
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Stamp Of Jamiah:",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Image(stampImage, width: 60, height: 60),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> downloadFeeReceipt(Feetransactionmodel feeTx) async {
    try {
      isLoading.value = true;
      if (Platform.isAndroid) await Permission.storage.request();

      final pdfBytes = await generateFeeReceiptPDF(feeTx);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'Receipt_${feeTx.receiptNo.replaceAll('/', '_')}_$timestamp.pdf';

      await _saveAndOpenPDF(pdfBytes, fileName);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to download receipt: $e');
    }
  }

  Future<Uint8List> generateFeeReceiptPDF(Feetransactionmodel feeTx) async {
    final student = _authController.currentStudent!;
    final pdf = pw.Document();

    // Images
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/riyazul.png')).buffer.asUint8List(),
    );

    final arbi = pw.MemoryImage(
      (await rootBundle.load('assets/images/spalsh1.png')).buffer.asUint8List(),
    );

    final stamp = pw.MemoryImage(
      (await rootBundle.load('assets/images/stamp.png')).buffer.asUint8List(),
    );

    final sign = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/feeslogo.png',
      )).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                child: pw.Column(
                  children: [
                    /// 🔹 HEADER
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "Managed by : Rahmat E Aalam Charitable Trust",
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            "Reg. No. : E/7941/Vadodara",
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(logo, width: 50),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          children: [
                            pw.Image(arbi, width: 180),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Mobile: 9104024313 / 9898610513",
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.Divider(),

                    /// 🔹 ACADEMIC YEAR
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          "Academic Year : ",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(feeTx.acedemicYear),
                      ],
                    ),

                    pw.Divider(),

                    /// 🔹 STUDENT INFO
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  "Receipt No : ${feeTx.receiptNo}",
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  "Date : ${DateFormat('dd MMM yyyy').format(feeTx.receivedDate)}",
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text("Student : ${student.name}"),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text("GR No : ${student.grNO}"),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  "Level : ${student.prevSchoolClass}",
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  "Address : ${student.addressHouseArea}",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    /// 🔹 TABLE
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        /// Header
                        pw.TableRow(
                          children: [
                            _cell("Sr No", bold: true),
                            _cell("Fees Type", bold: true),
                            _cell("Month", bold: true),
                            _cell("Amount", bold: true),
                          ],
                        ),

                        /// Data
                        ...List.generate(feeTx.feeDetails.length, (index) {
                          final fee = feeTx.feeDetails[index];

                          return pw.TableRow(
                            children: [
                              _cell("${index + 1}"),
                              _cell(fee['type'] ?? "-"),
                              _cell(
                                "${feeTx.startDate.monthYear()} - ${feeTx.endDate.monthYear()}",
                              ),
                              _cell("${fee['amount']}"),
                            ],
                          );
                        }),

                        /// Total row
                        pw.TableRow(
                          children: [
                            _cell("Payment Mode : ${feeTx.paymentMode}"),
                            _cell("Total Amount", bold: true),
                            _cell(""),
                            _cell(feeTx.totalAmt.toString(), bold: true),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 10),

                    /// 🔹 FOOTER
                    // pw.Padding(
                    //   padding: const pw.EdgeInsets.all(8),
                    //   child: pw.Row(
                    //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       pw.Text(
                    //         "Payment Mode : ${feeTx.paymentMode}",
                    //         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    //       ),

                    //       pw.Stack(
                    //         alignment: pw.Alignment.center,
                    //         children: [
                    //           pw.Image(stamp, width: 80),
                    //           pw.Image(sign, width: 60),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),

                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Align(
                            alignment: pw.Alignment.topRight,
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              // mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "Remarks : ",
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(feeTx.remarks),
                              ],
                            ),
                          ),

                          pw.Stack(
                            alignment: pw.Alignment(1, -1),
                            // alignment: pw.Alignment.bottomRight,
                            children: [
                              pw.Container(
                                alignment: pw.Alignment.center,
                                width: 80,
                                child: pw.Image(stamp),
                              ),
                              pw.Container(
                                alignment: pw.Alignment.center,
                                width: 70,
                                child: pw.Image(sign),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// 🔹 Helper widget
  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
