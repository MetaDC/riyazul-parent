// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:jamiah_riyazul/models/Studentmodel.dart';
// import 'package:jamiah_riyazul/models/notice_model.dart';
// import 'package:jamiah_riyazul/models/notification_model.dart';
// import 'package:jamiah_riyazul/shared/firebase.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';
// import 'package:rxdart/streams.dart';
// // ✅ add rxdart: ^0.27.7 to pubspec.yaml

// class NoticeService {
//   // ─────────────────────────────────────────────
//   // GENERATE + UPLOAD + NOTIFY
//   // ─────────────────────────────────────────────
//   static Future<void> generateAndSendNotice({
//     required String title,
//     required String body,
//     required String targetType, // 'all' | 'specific'
//     String? studentId,
//     required String adminUid,
//     required List<Studentmodel> allActiveStudents,
//   }) async {
//     // 1️⃣ Generate ONE pdf
//     final pdfBytes = await _generateNoticePDF(title, body);

//     // 2️⃣ Get notice doc ID
//     final noticeRef = FBFireStore.notices.doc();
//     final noticeId = noticeRef.id;

//     // 3️⃣ Upload ONE pdf to storage
//     final storageRef = FBStorage.notices.child('$noticeId/notice.pdf');
//     final uploadTask = await storageRef.putData(
//       pdfBytes,
//       SettableMetadata(contentType: 'application/pdf'),
//     );
//     final pdfUrl = await uploadTask.ref.getDownloadURL();

//     // 4️⃣ Save notice document
//     final notice = NoticeModel(
//       docId: noticeId,
//       title: title,
//       body: body,
//       pdfUrl: pdfUrl,
//       targetType: targetType,
//       studentId: studentId,
//       createdAt: DateTime.now(),
//       createdBy: adminUid,
//     );
//     await noticeRef.set(notice.toMap());

//     // 5️⃣ Create notification
//     final now = DateTime.now();

//     if (targetType == 'all') {
//       await FBFireStore.notifications.add({
//         'title': title,
//         'body': body,
//         'type': 'notice',
//         'targetType': 'all',
//         'studentId': null,
//         'pdfUrl': pdfUrl,
//         'createdAt': Timestamp.fromDate(now),
//         'isRead': false,
//       });
//     } else if (targetType == 'specific' && studentId != null) {
//       await FBFireStore.notifications.add({
//         'title': title,
//         'body': body,
//         'type': 'notice',
//         'targetType': 'specific',
//         'studentId': studentId,
//         'pdfUrl': pdfUrl,
//         'createdAt': Timestamp.fromDate(now),
//         'isRead': false,
//       });
//     }
//   }

//   // ─────────────────────────────────────────────
//   // MARK AS READ
//   // ─────────────────────────────────────────────
//   static Future<void> markAsRead({
//     required String notificationDocId,
//     required String targetType,
//     required String studentId,
//   }) async {
//     if (targetType == 'specific') {
//       await FBFireStore.notifications.doc(notificationDocId).update({
//         'isRead': true,
//       });
//     } else {
//       // 'all' — store per-student read state in subcollection
//       await FBFireStore.notifications
//           .doc(notificationDocId)
//           .collection('readBy')
//           .doc(studentId)
//           .set({'readAt': FieldValue.serverTimestamp()});
//     }
//   }

//   // ─────────────────────────────────────────────
//   // FIX #2 & #5: GET NOTIFICATIONS STREAM FOR STUDENT
//   // Uses CombineLatest so both streams update the UI correctly.
//   // isRead for 'all' notifications is resolved from readBy subcollection.
//   // ─────────────────────────────────────────────
//   static Stream<List<NotificationModel>> getStudentNotifications(
//     String studentId,
//   ) {
//     final broadcastStream =
//         FBFireStore.notifications
//             .where('targetType', isEqualTo: 'all')
//             .orderBy('createdAt', descending: true)
//             .snapshots();

//     final specificStream =
//         FBFireStore.notifications
//             .where('targetType', isEqualTo: 'specific')
//             .where('studentId', isEqualTo: studentId)
//             .orderBy('createdAt', descending: true)
//             .snapshots();

//     // ✅ CombineLatest: both streams update UI whenever either emits
//     return CombineLatestStream.combine2(broadcastStream, specificStream, (
//       QuerySnapshot broadcastSnap,
//       QuerySnapshot specificSnap,
//     ) {
//       final broadcast =
//           broadcastSnap.docs
//               .map((d) => NotificationModel.fromSnapshot(d))
//               .toList();
//       final specific =
//           specificSnap.docs
//               .map((d) => NotificationModel.fromSnapshot(d))
//               .toList();
//       final all = [...broadcast, ...specific];
//       all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return all;
//     });
//   }

//   // ─────────────────────────────────────────────
//   // FIX #5: CHECK IF BROADCAST NOTIFICATION IS READ BY STUDENT
//   // Call this per notification item in the UI to show correct read state.
//   // ─────────────────────────────────────────────
//   static Future<bool> isBroadcastRead({
//     required String notificationDocId,
//     required String studentId,
//   }) async {
//     final doc =
//         await FBFireStore.notifications
//             .doc(notificationDocId)
//             .collection('readBy')
//             .doc(studentId)
//             .get();
//     return doc.exists;
//   }

//   // ─────────────────────────────────────────────
//   // FIX #5: STREAM read state for a single broadcast notification
//   // Use this in your notification list item widget for live updates.
//   // ─────────────────────────────────────────────
//   static Stream<bool> broadcastReadStream({
//     required String notificationDocId,
//     required String studentId,
//   }) {
//     return FBFireStore.notifications
//         .doc(notificationDocId)
//         .collection('readBy')
//         .doc(studentId)
//         .snapshots()
//         .map((doc) => doc.exists);
//   }

//   // ─────────────────────────────────────────────
//   // FIX #1: GET UNREAD COUNT — no longer does N reads per notification
//   // Specific unread: simple Firestore query count
//   // Broadcast unread: cached in a top-level 'readBy' field on each doc
//   // ─────────────────────────────────────────────
//   static Stream<int> getUnreadCount(String studentId) {
//     // Specific: unread docs for this student
//     final specificStream = FBFireStore.notifications
//         .where('targetType', isEqualTo: 'specific')
//         .where('studentId', isEqualTo: studentId)
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .map((s) => s.docs.length);

//     // ✅ Broadcast: check readBy_{studentId} field on each doc (no subcollection reads)
//     // When markAsRead is called for 'all', also set this field:
//     //   'readByIds': FieldValue.arrayUnion([studentId])
//     // Then we count docs where studentId is NOT in readByIds
//     final broadcastStream = FBFireStore.notifications
//         .where('targetType', isEqualTo: 'all')
//         .snapshots()
//         .map((snap) {
//           int unread = 0;
//           for (final doc in snap.docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             final readByIds = List<String>.from(data['readByIds'] ?? []);
//             if (!readByIds.contains(studentId)) unread++;
//           }
//           return unread;
//         });
//     return CombineLatestStream.combine2(
//       specificStream,
//       broadcastStream,
//       (int a, int b) => a + b,
//     );
//   }

//   // ─────────────────────────────────────────────
//   // UPDATED markAsRead — also writes readByIds array for unread count fix
//   // ─────────────────────────────────────────────
//   static Future<void> markAsReadV2({
//     required String notificationDocId,
//     required String targetType,
//     required String studentId,
//   }) async {
//     if (targetType == 'specific') {
//       await FBFireStore.notifications.doc(notificationDocId).update({
//         'isRead': true,
//       });
//     } else {
//       // ✅ Write to both: subcollection (for broadcastReadStream)
//       //                  AND readByIds array (for efficient unread count)
//       final batch = FirebaseFirestore.instance.batch();

//       final readByRef = FBFireStore.notifications
//           .doc(notificationDocId)
//           .collection('readBy')
//           .doc(studentId);

//       final notifRef = FBFireStore.notifications.doc(notificationDocId);

//       batch.set(readByRef, {'readAt': FieldValue.serverTimestamp()});
//       batch.update(notifRef, {
//         'readByIds': FieldValue.arrayUnion([studentId]),
//       });

//       await batch.commit();
//     }
//   }

//   // ─────────────────────────────────────────────
//   // FIX #3: PDF GENERATION
//   // Arabic text is rendered as image (riyazularbi.png) — correct approach.
//   // Do NOT put Arabic strings as pw.Text — use pw.Image for Arabic content.
//   // ─────────────────────────────────────────────
//   static Future<Uint8List> _generateNoticePDF(String title, String body) async {
//     final pdf = pw.Document();

//     final logoImage = pw.MemoryImage(
//       (await rootBundle.load(
//         'assets/images/riyazullogo.png',
//       )).buffer.asUint8List(),
//     );
//     final nameImage = pw.MemoryImage(
//       (await rootBundle.load(
//         'assets/images/riyazularbi.png',
//       )).buffer.asUint8List(),
//     );
//     final stampImage = pw.MemoryImage(
//       (await rootBundle.load('assets/images/stamp.png')).buffer.asUint8List(),
//     );
//     final signImg = pw.MemoryImage(
//       (await rootBundle.load(
//         'assets/images/feeslogo.png',
//       )).buffer.asUint8List(),
//     );

//     // ✅ FIX #3: Load a font that supports the characters in title/body.
//     // If title/body is English only, this is fine as-is.
//     // If Arabic text can appear in title/body, you MUST either:
//     //   a) Use an Arabic-supporting TTF font loaded via rootBundle
//     //   b) Render the text as an image before passing to PDF
//     // Example for custom font:
//     // final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
//     // final arabicFont = pw.Font.ttf(fontData);
//     // Then use: pw.TextStyle(font: arabicFont)

//     final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         build:
//             (context) => pw.Container(
//               decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
//               padding: const pw.EdgeInsets.all(12),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // ── HEADER ──
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.center,
//                     children: [
//                       pw.Text(
//                         "MANAGED BY RAHMAT E AALAM CHARITABLE TRUST",
//                         style: const pw.TextStyle(fontSize: 10),
//                       ),
//                       pw.SizedBox(width: 20),
//                       pw.Text(
//                         "NO. E/7941/VADODARA",
//                         style: const pw.TextStyle(fontSize: 10),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(height: 5),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.center,
//                     children: [
//                       pw.Expanded(
//                         flex: 3,
//                         child: pw.Center(
//                           child: pw.Text(
//                             "JAMIAH RIYAZUL ULOOM (BARODA)",
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                             textAlign: pw.TextAlign.center,
//                           ),
//                         ),
//                       ),
//                       pw.SizedBox(width: 10),
//                       pw.Image(logoImage, width: 50, height: 50),
//                       pw.SizedBox(width: 10),
//                       pw.Expanded(
//                         flex: 3,
//                         child: pw.Image(
//                           nameImage,
//                           height: 40,
//                           fit: pw.BoxFit.contain,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(height: 5),
//                   pw.Center(
//                     child: pw.Column(
//                       children: [
//                         pw.Text(
//                           "KADU NI PAGA, MACHCHIPITH, VADODARA-01",
//                           style: pw.TextStyle(fontSize: 10),
//                         ),
//                         pw.Text(
//                           "9104024313 / 9898610513",
//                           style: pw.TextStyle(fontSize: 11),
//                         ),
//                       ],
//                     ),
//                   ),
//                   pw.Divider(thickness: 2),
//                   pw.SizedBox(height: 25),

//                   // ── TITLE ──
//                   pw.Center(
//                     child: pw.Text(
//                       title.toUpperCase(),
//                       style: pw.TextStyle(
//                         fontSize: 18,
//                         fontWeight: pw.FontWeight.bold,
//                         decoration: pw.TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Align(
//                     alignment: pw.Alignment.centerRight,
//                     child: pw.Text(
//                       "Date: $dateStr",
//                       style: const pw.TextStyle(fontSize: 12),
//                     ),
//                   ),
//                   pw.SizedBox(height: 30),

//                   // ── BODY ──
//                   pw.Expanded(
//                     child: pw.Text(
//                       body,
//                       style: const pw.TextStyle(fontSize: 14),
//                       textAlign: pw.TextAlign.justify,
//                     ),
//                   ),
//                   pw.SizedBox(height: 30),

//                   // ── FOOTER ──
//                   pw.Divider(),
//                   pw.SizedBox(height: 15),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       // LEFT SIDE - Principal Sign
//                       pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             "Principal's Sign:",
//                             style: pw.TextStyle(fontSize: 12),
//                           ),
//                           pw.SizedBox(height: 8), // <-- Space after text
//                           pw.Image(
//                             signImg,
//                             width: 70,
//                             height: 50,
//                             fit: pw.BoxFit.contain,
//                           ),
//                         ],
//                       ),

//                       // RIGHT SIDE - Stamp
//                       pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           pw.Text(
//                             "Stamp Of Jamiah:",
//                             style: pw.TextStyle(fontSize: 12),
//                           ),
//                           pw.SizedBox(height: 8),
//                           pw.ClipOval(
//                             // <-- Makes image round
//                             child: pw.Image(
//                               stampImage,
//                               width: 70,
//                               height: 70,
//                               fit: pw.BoxFit.cover,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//       ),
//     );

//     return pdf.save();
//   }
// }
