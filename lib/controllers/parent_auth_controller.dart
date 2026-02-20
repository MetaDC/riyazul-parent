import 'package:get/get.dart';
import 'package:riyazul_parent/models/studentmodel.dart';
import 'package:riyazul_parent/models/feeTransactionmodel.dart';
import 'package:riyazul_parent/models/resultmodel.dart';
import 'package:riyazul_parent/models/classmodel.dart';
import 'package:riyazul_parent/shared/firebase.dart';
import 'package:flutter/material.dart';

import 'package:riyazul_parent/shared/routes.dart';

class ParentAuthController extends GetxController {
  var isLoading = false.obs;
  Studentmodel? currentStudent;

  // RxLists for student-specific data
  var studentResults = <Resultmodel>[].obs;
  var studentFees = <Feetransactionmodel>[].obs;

  var schoolClassName = ''.obs;
  var deeniyatClassName = ''.obs;
  var totalDays = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> login(String grNo, DateTime dob) async {
    try {
      isLoading.value = true;

      // Firestore query by GR NO
      final querySnapshot = await FBFireStore.students
          .where('grNO', isEqualTo: grNo)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          'Error',
          'Student not found with this GR Number.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // Check DOB locally due to Firestore exact timestamp constraints
      bool studentFound = false;
      for (var doc in querySnapshot.docs) {
        final student = Studentmodel.fromSnapshot(doc);

        if (student.dob.year == dob.year &&
            student.dob.month == dob.month &&
            student.dob.day == dob.day) {
          currentStudent = student;
          studentFound = true;
          break;
        }
      }

      if (studentFound) {
        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Fetch remaining data
        await fetchStudentData();

        Get.offNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          'Error',
          'Date of Birth does not match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
    } catch (e) {
      debugPrint('Error fetching student data: $e');
    }
  }

  void logout() {
    currentStudent = null;
    studentResults.clear();
    studentFees.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
