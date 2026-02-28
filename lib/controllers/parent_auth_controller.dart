import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/models/notificationmodel.dart';
import 'package:riyazul_parent/models/studentmodel.dart';
import 'package:riyazul_parent/models/feeTransactionmodel.dart';
import 'package:riyazul_parent/models/resultmodel.dart';
import 'package:riyazul_parent/models/classmodel.dart';
import 'package:riyazul_parent/models/sabakmodel.dart';
import 'package:riyazul_parent/models/complaintmodel.dart';
import 'package:riyazul_parent/shared/firebase.dart';
import 'package:flutter/material.dart';

import 'package:riyazul_parent/shared/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class ParentAuthController extends GetxController {
  var isLoading = false.obs;
  Studentmodel? currentStudent;

  var studentResults = <Resultmodel>[].obs;
  var studentFees = <Feetransactionmodel>[].obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  var sabakList = <Sabakmodel>[].obs;
  var complaintsList = <Complaintmodel>[].obs;
  var presentAttendanceCount = 0.obs;
  var absentAttendanceCount = 0.obs;
  StreamSubscription? _notificationSubscription;
  var schoolClassName = ''.obs;
  var deeniyatClassName = ''.obs;
  var totalDays = '';

  // SharedPreferences keys
  static const _keyGrNo = 'saved_gr_no';
  static const _keyDobStr = 'saved_dob_str'; // stored as 'yyyy-MM-dd'

  @override
  void onInit() {
    super.onInit();
    tryAutoLogin(); // ← attempt auto-login on app start
  }

  // ── Auto-login on startup ─────────────────────────────────────────────────
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final grNo = prefs.getString(_keyGrNo);
    final dobStr = prefs.getString(_keyDobStr);

    if (grNo != null && dobStr != null) {
      // Parse as UTC midnight — same representation we compare against
      final parts = dobStr.split('-');
      final dob = DateTime.utc(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      await login(grNo, dob, fromAutoLogin: true);
    }
  }

  // ── Save credentials locally ──────────────────────────────────────────────
  Future<void> _saveCredentials(String grNo, DateTime dob) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGrNo, grNo);
    // Store as 'yyyy-MM-dd' — timezone-safe, no millis offset issues
    final dobStr =
        '${dob.year.toString().padLeft(4, '0')}-'
        '${dob.month.toString().padLeft(2, '0')}-'
        '${dob.day.toString().padLeft(2, '0')}';
    await prefs.setString(_keyDobStr, dobStr);
  }

  // ── Clear saved credentials ───────────────────────────────────────────────
  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGrNo);
    await prefs.remove(_keyDobStr);
  }

  // ── Get Unique Device ID ──────────────────────────────────────────────────
  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.id.isNotEmpty) return androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (iosInfo.identifierForVendor != null &&
            iosInfo.identifierForVendor!.isNotEmpty) {
          return iosInfo.identifierForVendor!;
        }
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
    }

    // Fallback ID if cannot get hardware info
    final prefs = await SharedPreferences.getInstance();
    const fallbackKey = 'fallback_device_uuid';
    String? fallbackId = prefs.getString(fallbackKey);
    if (fallbackId == null) {
      fallbackId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(fallbackKey, fallbackId);
    }
    return fallbackId;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(
    String grNo,
    DateTime dob, {
    bool fromAutoLogin = false,
  }) async {
    try {
      isLoading.value = true;

      List<QueryDocumentSnapshot<Map<String, dynamic>>> studentDocs = [];

      // Variation 1: grNO (String)
      var snap = await FBFireStore.students
          .where('grNO', isEqualTo: grNo)
          .get();
      studentDocs = snap.docs;

      // Variation 2: grNO (Number)
      if (studentDocs.isEmpty && RegExp(r'^\d+$').hasMatch(grNo)) {
        snap = await FBFireStore.students
            .where('grNO', isEqualTo: int.parse(grNo))
            .get();
        studentDocs = snap.docs;
      }

      // Variation 3: grNo (String)
      if (studentDocs.isEmpty) {
        snap = await FBFireStore.students.where('grNo', isEqualTo: grNo).get();
        studentDocs = snap.docs;
      }

      // Variation 4: grNo (Number)
      if (studentDocs.isEmpty && RegExp(r'^\d+$').hasMatch(grNo)) {
        snap = await FBFireStore.students
            .where('grNo', isEqualTo: int.parse(grNo))
            .get();
        studentDocs = snap.docs;
      }

      if (studentDocs.isEmpty) {
        if (!fromAutoLogin) {
          Get.snackbar(
            'Error',
            'Student not found with this GR Number.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
        isLoading.value = false;
        return;
      }

      bool studentFound = false;
      for (var doc in studentDocs) {
        final student = Studentmodel.fromSnapshot(doc);
        final studentDob = DateTime.utc(
          student.dob.year,
          student.dob.month,
          student.dob.day,
        );
        final inputDob = DateTime.utc(dob.year, dob.month, dob.day);

        debugPrint(
          'Comparing DOB: Input=$inputDob, Student($grNo)=${student.dob} (Normalized to $studentDob)',
        );

        if (studentDob == inputDob) {
          currentStudent = student;
          studentFound = true;
          break;
        } else {
          debugPrint(
            'DOB Mismatch for student $grNo: '
            'Input=$inputDob vs Stored=$studentDob '
            '(Raw stored student.dob was ${student.dob})',
          );
        }
      }

      if (studentFound) {
        final String currentDeviceId = await _getDeviceId();

        await FBFireStore.students.doc(currentStudent!.docId).update({
          'isInstalledAppUser': true,
          'loginDeviceIds': FieldValue.arrayUnion([currentDeviceId]),
          'lastLoginDatetime': FieldValue.serverTimestamp(),
        });

        await _saveCredentials(grNo, dob);

        if (!fromAutoLogin) {
          Get.snackbar(
            'Success',
            'Logged in successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }

        await fetchStudentData();
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        if (!fromAutoLogin) {
          Get.snackbar(
            'Error',
            'Date of Birth does not match.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      if (!fromAutoLogin) {
        Get.snackbar(
          'Error',
          'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout with confirmation ──────────────────────────────────────────────
  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2C326F),
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2C326F),
              foregroundColor: const Color(0xffFFF2CD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performLogout() async {
    await _clearCredentials();
    currentStudent = null;
    studentResults.clear();
    studentFees.clear();
    sabakList.clear();
    complaintsList.clear();
    presentAttendanceCount.value = 0;
    absentAttendanceCount.value = 0;
    schoolClassName.value = '';
    deeniyatClassName.value = '';
    totalDays = '';
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> fetchStudentData() async {
    if (currentStudent == null) return;
    final String sId = currentStudent!.docId;

    try {
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> resFutures = [
        FBFireStore.results.where('studentId', isEqualTo: sId).get(),
        FBFireStore.results.where('studId', isEqualTo: sId).get(),
        FBFireStore.results
            .where('studentId', isEqualTo: currentStudent!.grNO)
            .get(),
        FBFireStore.results
            .where('studId', isEqualTo: currentStudent!.grNO)
            .get(),
      ];

      // Numeric fallbacks for Results
      if (RegExp(r'^\d+$').hasMatch(currentStudent!.grNO)) {
        final grInt = int.parse(currentStudent!.grNO);
        resFutures.add(
          FBFireStore.results.where('studentId', isEqualTo: grInt).get(),
        );
        resFutures.add(
          FBFireStore.results.where('studId', isEqualTo: grInt).get(),
        );
      }

      final resSnaps = await Future.wait(resFutures);

      final allResDocs = resSnaps.expand((s) => s.docs).toList();
      final seenResIds = <String>{};
      studentResults.value = allResDocs
          .where((doc) => seenResIds.add(doc.id))
          .map((e) => Resultmodel.fromSnapshot(e))
          .toList();

      // 2. Fetch Fees (Check both labels)
      final feeResults = await Future.wait([
        FBFireStore.feetranscationdetails.where('studId', isEqualTo: sId).get(),
        FBFireStore.feetranscationdetails
            .where('studentId', isEqualTo: sId)
            .get(),
      ]);
      final allFeeDocs = [...feeResults[0].docs, ...feeResults[1].docs];
      final seenFeeIds = <String>{};
      studentFees.value =
          allFeeDocs
              .where((doc) => seenFeeIds.add(doc.id))
              .map((e) => Feetransactionmodel.fromSnapshot(e))
              .toList()
            ..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));

      // 3. Fetch Classes & Settings individually to avoid Future.wait type conflicts
      // ✅ FIX: Typed as DocumentSnapshot<Map<String,dynamic>> to match ClassModel.fromSnapshot
      final DocumentSnapshot<Map<String, dynamic>>? schoolDoc =
          (currentStudent!.currentSchoolStd?.isNotEmpty ?? false)
          ? await FBFireStore.classes
                .doc(currentStudent!.currentSchoolStd)
                .get()
          : null;

      final DocumentSnapshot<Map<String, dynamic>>? deeniyatDoc =
          currentStudent!.currentDeeniyat.isNotEmpty
          ? await FBFireStore.classes.doc(currentStudent!.currentDeeniyat).get()
          : null;

      final totalDaysDoc = await FBFireStore.totalDays.get();

      if (schoolDoc != null && schoolDoc.exists)
        schoolClassName.value = ClassModel.fromSnapshot(schoolDoc).className;

      if (deeniyatDoc != null && deeniyatDoc.exists)
        deeniyatClassName.value = ClassModel.fromSnapshot(
          deeniyatDoc,
        ).className;

      if (totalDaysDoc.exists)
        totalDays = totalDaysDoc.data()?['days']?.toString() ?? '';
      // 4. Sabak (CLEAN FIXED VERSION)

      final sabSnap = await FBFireStore.sabaks
          .where('studentId', isEqualTo: currentStudent!.docId)
          .get();

      print("Sabak Query StudentId: ${currentStudent!.docId}");
      print("Sabak Docs Found: ${sabSnap.docs.length}");

      sabakList.value =
          sabSnap.docs.map((e) => Sabakmodel.fromSnapshot(e)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 5. Complaints (Robust Strategy)
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> cmpFutures = [
        FBFireStore.complaints.where('studentId', isEqualTo: sId).get(),
        FBFireStore.complaints.where('studId', isEqualTo: sId).get(),
        FBFireStore.complaints
            .where('studentId', isEqualTo: currentStudent!.grNO)
            .get(),
        FBFireStore.complaints
            .where('studId', isEqualTo: currentStudent!.grNO)
            .get(),
      ];

      // Numeric fallbacks for Complaints
      if (RegExp(r'^\d+$').hasMatch(currentStudent!.grNO)) {
        final grInt = int.parse(currentStudent!.grNO);
        cmpFutures.add(
          FBFireStore.complaints.where('studentId', isEqualTo: grInt).get(),
        );
        cmpFutures.add(
          FBFireStore.complaints.where('studId', isEqualTo: grInt).get(),
        );
      }

      final cmpSnaps = await Future.wait(cmpFutures);

      final allCmpDocs = cmpSnaps.expand((s) => s.docs).toList();
      final seenCmpIds = <String>{};
      complaintsList.value =
          allCmpDocs
              .where((doc) => seenCmpIds.add(doc.id))
              .map((e) => Complaintmodel.fromSnapshot(e))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 6. Attendance
      final attResults = await Future.wait([
        FBFireStore.attendance.where('presentStudId', arrayContains: sId).get(),
        FBFireStore.attendance.where('absentStudId', arrayContains: sId).get(),
      ]);
      presentAttendanceCount.value = attResults[0].docs.length;
      absentAttendanceCount.value = attResults[1].docs.length;

      fetchNotifications(sId);
    } catch (e) {
      debugPrint('Error fetching student data: $e');
    }
  }

  // ── Notifications (real-time, leak-safe) ─────────────────────────────────
  void fetchNotifications(String studentId) {
    _notificationSubscription?.cancel();

    final s1 = FirebaseFirestore.instance
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .snapshots();
    final s2 = FirebaseFirestore.instance
        .collection('notifications')
        .where('studId', isEqualTo: studentId)
        .snapshots();
    final s3 = FirebaseFirestore.instance
        .collection('notifications')
        .where('targetType', isEqualTo: 'all')
        .snapshots();

    _notificationSubscription =
        rx.Rx.combineLatest3(s1, s2, s3, (
          QuerySnapshot q1,
          QuerySnapshot q2,
          QuerySnapshot q3,
        ) {
          final List<NotificationModel> combined = [];
          final Set<String> ids = {};
          void add(QuerySnapshot s) {
            for (var d in s.docs) {
              if (ids.add(d.id)) {
                combined.add(
                  NotificationModel.fromSnapshot(
                    d,
                    currentStudentId: studentId,
                  ),
                );
              }
            }
          }

          add(q1);
          add(q2);
          add(q3);
          combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return combined;
        }).listen((list) {
          notifications.value = list;
          unreadCount.value = list.where((n) => !n.isRead).length;
        });
  }

  // ── Mark a single notification as read ───────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    final notif = notifications.firstWhereOrNull(
      (n) => n.docId == notificationId,
    );
    if (notif == null) return;

    if (notif.targetType == 'all') {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
            'readBy': FieldValue.arrayUnion([currentStudent!.docId]),
          });
    } else {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllAsRead(String studentId) async {
    final batch = FirebaseFirestore.instance.batch();

    // Specific notifications
    final unreadSpecific = await FirebaseFirestore.instance
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in unreadSpecific.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Global notifications
    final unreadGlobal = notifications.where(
      (n) => n.targetType == 'all' && !n.isRead,
    );
    for (var notif in unreadGlobal) {
      final docRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc(notif.docId);
      batch.update(docRef, {
        'readBy': FieldValue.arrayUnion([studentId]),
      });
    }

    await batch.commit();
  }
}
