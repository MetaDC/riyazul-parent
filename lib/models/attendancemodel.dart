import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String? docId;
  // final String stuId;
  final String classId;
  final String subjectId;
  final DateTime dateTime;
  final DateTime createdAt;
  // final bool isPresent;
  final List<String>? presentStudId;
  final List<String>? absentStudId;

  AttendanceModel({
    this.docId,
    // required this.stuId,
    required this.classId,
    required this.subjectId,
    required this.dateTime,
    // required this.isPresent,
    required this.createdAt,
    this.presentStudId,
    this.absentStudId,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'docId': docId,
      // 'stuId': stuId,
      'classId': classId,
      'subjectId': subjectId,
      'dateTime': Timestamp.fromDate(dateTime),
      'createdAt': Timestamp.fromDate(createdAt),
      // 'isPresent': isPresent,
      'presentStudId': presentStudId,
      'absentStudId': absentStudId,
    };
  }

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceModel(
      docId: id,
      // stuId: map['stuId'],
      classId: map['classId'],
      subjectId: map['subjectId'],
      dateTime: (map['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // isPresent: map['isPresent'] ?? false,
      presentStudId: (map['presentStudId'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      absentStudId: (map['absentStudId'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  factory AttendanceModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AttendanceModel.fromMap(snapshot.id, data);
  }
}
