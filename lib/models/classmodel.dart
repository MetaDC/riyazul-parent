import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String classId;
  final String className;
  final String courseId;
  final List<String> subjectList;
  final bool isSchool;

  ClassModel({
    required this.classId,
    required this.className,
    required this.subjectList,
    required this.courseId,
    required this.isSchool,
  });

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'className': className,
      'subjectList': subjectList,
      'courseId': courseId,
      'isSchool': isSchool,
    };
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      classId: json['classId'],
      className: json['className'],
      subjectList: List.from(json['subjectList']),
      courseId: json['courseId'],

      isSchool: json['isSchool'],
    );
  }

  factory ClassModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    Map<String, dynamic> classData = snapshot.data() as Map<String, dynamic>;

    // print("Class Data: $classData");

    return ClassModel(
      classId: snapshot.id,
      className: classData['className'],
      subjectList: List.from(classData['subjectList']),
      courseId: classData['courseId'],
      isSchool: classData['isSchool'] ?? false,
    );
  }
}
