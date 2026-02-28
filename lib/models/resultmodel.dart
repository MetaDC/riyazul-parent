import 'package:cloud_firestore/cloud_firestore.dart';

class Resultmodel {
  final String docId;
  final String title;
  final String studentId;
  final String courseType;
  final String classId;
  final String className;
  final List<SubjectResultModel> subjects;
  final String remarks;
  final String totalMarks;
  final String presentDays;
  final DateTime resultDate;
  final String academicYear;

  Resultmodel({
    required this.docId,
    required this.title,
    required this.studentId,
    required this.courseType,
    required this.classId,
    required this.className,
    required this.subjects,
    required this.remarks,
    required this.totalMarks,
    required this.presentDays,
    required this.resultDate,
    required this.academicYear,
  });

  /// ✅ ADD THIS
  factory Resultmodel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Resultmodel.fromJson(snapshot.id, data);
  }

  factory Resultmodel.fromJson(String docId, Map<String, dynamic> json) {
    return Resultmodel(
      docId: docId,
      title: json['title'] ?? '',
      studentId: json['studentId'] ?? json['studId'] ?? '',
      courseType: json['courseType'] ?? '',
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      remarks: json['remarks'] ?? '',
      totalMarks: json['totalMarks'] ?? '',
      presentDays: json['presentDays'] ?? '',
      academicYear: json['academicYear'] ?? '',
      resultDate:
          (json['resultDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subjects: (json['subjects'] as List? ?? [])
          .map((e) => SubjectResultModel.fromMap(e))
          .toList(),
    );
  }
}

class SubjectResultModel {
  final String subId;
  final String subName;
  final String sem1Marks;
  final String sem2Marks;
  final String subMarks;
  final String gRemarks;
  final bool isOptional;
  final String subClass;

  SubjectResultModel({
    required this.subId,
    required this.subName,
    required this.sem1Marks,
    required this.sem2Marks,
    required this.subMarks,
    required this.gRemarks,
    required this.isOptional,
    required this.subClass,
  });

  factory SubjectResultModel.fromMap(Map<String, dynamic> map) {
    return SubjectResultModel(
      subId: map['subId'] ?? '',
      subName: map['subName'] ?? '',
      sem1Marks: map['sem1Marks'] ?? '',
      sem2Marks: map['sem2Marks'] ?? '',
      subMarks: map['subMarks'] ?? '',
      gRemarks: map['gRemarks'] ?? '',
      isOptional: map['isOptional'] ?? false,
      subClass: map['subClass'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subId': subId,
      'subName': subName,
      'sem1Marks': sem1Marks,
      'sem2Marks': sem2Marks,
      'subMarks': subMarks,
      'gRemarks': gRemarks,
      'isOptional': isOptional,
      'subClass': subClass,
    };
  }
}
