import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/models/notificationmodel.dart';
import 'package:riyazul_parent/models/studentmodel.dart';
import 'package:riyazul_parent/models/feeTransactionmodel.dart';
import 'package:riyazul_parent/models/resultmodel.dart';
import 'package:riyazul_parent/models/classmodel.dart';
import 'package:riyazul_parent/shared/firebase.dart';
import 'package:flutter/material.dart';

import 'package:riyazul_parent/shared/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart' as rx;

class ParentAuthController extends GetxController {
  var isLoading = false.obs;
  Studentmodel? currentStudent;

  var studentResults = <Resultmodel>[].obs;
  var studentFees = <Feetransactionmodel>[].obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

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

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(
    String grNo,
    DateTime dob, {
    bool fromAutoLogin = false,
  }) async {
    try {
      isLoading.value = true;

      // --- Robust Login Query Strategy ---
      // Try multiple variations to find the student:
      // 1. grNO as String
      // 2. grNO as Number (if numeric)
      // 3. grNo as String
      // 4. grNo as Number (if numeric)

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
        // student.dob is already UTC midnight (from _dobFromTimestamp)
        final studentDob = DateTime.utc(
          student.dob.year,
          student.dob.month,
          student.dob.day,
        );
        // Normalize input to UTC midnight as well
        final inputDob = DateTime.utc(dob.year, dob.month, dob.day);

        // Debug print to help identify mismatch if it still fails
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
        await _saveCredentials(grNo, dob); // ← persist on success

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
    await _clearCredentials(); // ← wipe saved creds
    currentStudent = null;
    studentResults.clear();
    studentFees.clear();
    schoolClassName.value = '';
    deeniyatClassName.value = '';
    totalDays = '';
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> fetchStudentData() async {
    if (currentStudent == null) return;
    try {
      // Fetch Results specific to student
      final resultSnap = await FBFireStore.results
          .where('studentId', isEqualTo: currentStudent!.docId)
          .get();
      studentResults.value = resultSnap.docs
          .map((e) => Resultmodel.fromSnapshot(e))
          .toList();

      // Fetch Fees specific to student
      final feeSnap = await FBFireStore.feetranscationdetails
          .where('studId', isEqualTo: currentStudent!.docId)
          .orderBy('receivedDate', descending: true)
          .get();
      studentFees.value = feeSnap.docs
          .map((e) => Feetransactionmodel.fromSnapshot(e))
          .toList();

      // Fetch School Class Name
      if (currentStudent!.currentSchoolStd != null &&
          currentStudent!.currentSchoolStd!.isNotEmpty) {
        final doc = await FBFireStore.classes
            .doc(currentStudent!.currentSchoolStd)
            .get();
        if (doc.exists) {
          schoolClassName.value = ClassModel.fromSnapshot(doc).className;
        }
      }

      // Fetch Deeniyat Class Name
      if (currentStudent!.currentDeeniyat.isNotEmpty) {
        final doc = await FBFireStore.classes
            .doc(currentStudent!.currentDeeniyat)
            .get();
        if (doc.exists) {
          deeniyatClassName.value = ClassModel.fromSnapshot(doc).className;
        }
      }

      // Fetch Total Days (School Settings)
      final totalDaysDoc = await FBFireStore.totalDays.get();
      if (totalDaysDoc.exists) {
        final data = totalDaysDoc.data();
        if (data != null && data['days'] != null) {
          totalDays = data['days'].toString();
        }
      }

      // Start listening for notifications
      fetchNotifications(currentStudent!.docId);
    } catch (e) {
      debugPrint('Error fetching student data: $e');
    }
  }

  // Call this after student login is confirmed
  void fetchNotifications(String studentId) {
    final specificStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .snapshots();

    final globalStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('targetType', isEqualTo: 'all')
        .snapshots();

    rx.Rx.combineLatest2(specificStream, globalStream, (
      QuerySnapshot specific,
      QuerySnapshot global,
    ) {
      final List<NotificationModel> combined = [];
      final Set<String> ids = {};

      void addUnique(QuerySnapshot snap) {
        for (var doc in snap.docs) {
          if (!ids.contains(doc.id)) {
            combined.add(
              NotificationModel.fromSnapshot(doc, currentStudentId: studentId),
            );
            ids.add(doc.id);
          }
        }
      }

      addUnique(specific);
      addUnique(global);

      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
    }).listen((updatedList) {
      notifications.value = updatedList;
      unreadCount.value = updatedList.where((n) => !n.isRead).length;
    });
  }

  // Mark a single notification as read
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

  // Mark all as read
  Future<void> markAllAsRead(String studentId) async {
    final batch = FirebaseFirestore.instance.batch();

    // For specific
    final unreadSpecific = await FirebaseFirestore.instance
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in unreadSpecific.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // For global
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
