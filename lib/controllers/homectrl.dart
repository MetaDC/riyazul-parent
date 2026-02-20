import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riyazul_parent/models/classmodel.dart';
import 'package:riyazul_parent/models/coursemodel.dart';
import 'package:riyazul_parent/models/feemodel.dart';
import 'package:riyazul_parent/models/resultmodel.dart';
import 'package:riyazul_parent/models/studentmodel.dart';
import 'package:riyazul_parent/models/studentnotemodel.dart';
import 'package:riyazul_parent/models/subjectmodel.dart';
import 'package:riyazul_parent/shared/firebase.dart';

class Homectrl extends GetxController {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subjectStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? classStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? courseStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? teacherStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? studentStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? feeDetailsStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? resultsStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  feeTranscationDetailsStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? attendanceStream;
  bool isLoading = false;
  bool isSaving = false;

  @override
  void onInit() {
    super.onInit();
    getCourseData();
    getsubjectdata();
    getClassData();
    getStudentData();
    getFeeData();
    // getAllFeesTranscation();
    getResults();

    // getAttendance();
  }

  void setLoading(bool value) {
    isLoading = value;
    isSaving = value;
    update();
  }

  List<SubjectModel> allSubjects = [];
  List<ClassModel> allClasses = [];
  List<ClassModel> schoolClasses = [];
  List<Coursemodel> allCourses = [];

  List<Studentmodel> allStudents = [];
  List<Feemodel> allFeeDetails = [];
  // List<Feetransactionmodel> allFeesTranscation = [];
  // List<AttendanceModel> allAttendance = [];
  List<Resultmodel> results = [];
  List<StudentNoteModel> records = [];
  String searchQuery = '';
  String searchStudQuery = '';

  // getAllFeesTranscation() async {
  //   try {
  //     feeTranscationDetailsStream?.cancel();
  //     feeTranscationDetailsStream = FBFireStore.feetranscationdetails
  //         .orderBy("receivedDate")
  //         .snapshots()
  //         .listen((event) {
  //           print("total Transcat");
  //           print(event.size);
  //           allFeesTranscation =
  //               event.docs
  //                   .map((e) => Feetransactionmodel.fromSnapshot(e))
  //                   .toList();

  //           update();
  //         });
  //   } catch (e) {
  //     print("code Error$e");
  //   }
  // }

  getsubjectdata() async {
    try {
      subjectStream?.cancel();
      subjectStream = FBFireStore.subjects.snapshots().listen((event) {
        debugPrint("total Subject");
        debugPrint(event.size.toString());
        allSubjects = event.docs
            .map((e) => SubjectModel.fromSnapshot(e))
            .toList();
        debugPrint(allSubjects.length.toString());
        update();
      });
    } catch (e) {
      debugPrint("code Error$e");
    }
  }

  getStudentData() async {
    try {
      await studentStream?.cancel();
      studentStream = FBFireStore.students.snapshots().listen((event) {
        debugPrint("Total student");
        debugPrint(event.size.toString());
        allStudents = event.docs
            .map((e) => Studentmodel.fromSnapshot(e))
            .toList();
        debugPrint(allStudents.length.toString());
        update();
      });
    } catch (e) {
      debugPrint("code Error$e");
    }
  }

  getClassData() async {
    try {
      await classStream?.cancel();

      classStream = FBFireStore.classes.snapshots().listen((classEvent) {
        debugPrint("Total classes: ${classEvent.size}");
        allClasses = classEvent.docs
            .map((doc) => ClassModel.fromSnapshot(doc))
            .toList();
        update();
      });
    } catch (e) {
      debugPrint("Error in getClassData: $e");
    }
  }

  getCourseData() async {
    try {
      courseStream?.cancel();
      courseStream = FBFireStore.courses.snapshots().listen((courseEvent) {
        debugPrint("Total course data");
        debugPrint(courseEvent.size.toString());
        allCourses = courseEvent.docs
            .map((e) => Coursemodel.fromSnapshot(e))
            .toList();
        update();
      });
    } catch (e) {
      debugPrint("error on your getcoursecode $e");
    }
  }

  getFeeData() async {
    try {
      feeDetailsStream?.cancel();
      feeDetailsStream = FBFireStore.feedetails.snapshots().listen((
        feeDetailEvent,
      ) {
        debugPrint("Total fee details");
        debugPrint(feeDetailEvent.size.toString());
        allFeeDetails = feeDetailEvent.docs
            .map((e) => Feemodel.fromSnapshot(e))
            .toList();
        update();
      });
    } catch (e) {
      debugPrint("error on you getfee$e");
    }
  }

  getResults() async {
    try {
      resultsStream?.cancel();
      resultsStream = FBFireStore.results.snapshots().listen((event) {
        results = event.docs.map((e) => Resultmodel.fromSnapshot(e)).toList();
        update();
      });
    } catch (e) {
      debugPrint("error on you getResults $e");
    }
  }

  // getAttendance() async {
  //   try {
  //     attendanceStream?.cancel();
  //     attendanceStream = FBFireStore.attendance.snapshots().listen((event) {
  //       print("Total attendance ${event.size}");
  //       allAttendance =
  //           event.docs.map((e) => AttendanceModel.fromSnapshot(e)).toList();
  //       update();
  //     });
  //   } catch (e) {
  //     print("error on you getfee$e");
  //   }
  // }

  void updateSearchQuery(String query) {
    searchQuery = query;
    update();
  }

  List<Studentmodel> get filteredStudents {
    if (searchStudQuery.isEmpty) return allStudents;

    return allStudents.where((student) {
      final stQuery = searchStudQuery.toLowerCase();
      return student.name.toLowerCase().contains(stQuery) ||
          student.addressHouseArea.toLowerCase().contains(stQuery) ||
          student.grNO.toLowerCase().contains(stQuery);
    }).toList();
  }

  void updateSearchStudentQuery(String stQuery) {
    searchStudQuery = stQuery;
    update();
  }

  Future<void> getStudentRecords(String studentDocId) async {
    try {
      final snap = await FBFireStore.studentNotes
          .where('studentId', isEqualTo: studentDocId)
          .orderBy('date', descending: true)
          .get();

      records = snap.docs.map((e) => StudentNoteModel.fromSnapshot(e)).toList();

      update();
    } catch (e) {
      debugPrint('Firestore index not ready yet: $e');
    }
  }

  Future<void> addRecord({
    required Studentmodel student,
    required String date,
    required String para,
    required String remarks,
  }) async {
    final record = StudentNoteModel(
      docId: '',
      studentId: student.docId,
      studentName: student.name,
      date: DateTime.parse(date),
      para: para,
      remarks: remarks,
    );

    await FBFireStore.studentNotes.add(record.toMap());

    await getStudentRecords(student.docId);
  }
  // Add these methods to your Homectrl class

  Future<void> updateRecord({
    required String recordId,
    required String date,
    required String para,
    required String remarks,
  }) async {
    try {
      await FBFireStore.studentNotes.doc(recordId).update({
        'date': DateTime.parse(date),
        'para': para,
        'remarks': remarks,
      });

      // Refresh the records list
      // Get the studentId from the current records to refresh
      if (records.isNotEmpty) {
        final studentId = records.first.studentId;
        await getStudentRecords(studentId);
      }

      update();
    } catch (e) {
      debugPrint('Error updating record: $e');
      rethrow;
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await FBFireStore.studentNotes.doc(recordId).delete();

      // Remove from local list
      records.removeWhere((record) => record.docId == recordId);

      update();
    } catch (e) {
      debugPrint('Error deleting record: $e');
      rethrow;
    }
  }
}
