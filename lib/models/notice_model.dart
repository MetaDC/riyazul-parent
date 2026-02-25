import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String docId;
  final String title;
  final String body;
  final String targetType; // 'all' | 'specific'
  final String? studentId;
  final String? studentName;
  final String? grNo;
  final DateTime createdAt;
  final String createdBy;

  NoticeModel({
    required this.docId,
    required this.title,
    required this.body,
    required this.targetType,
    this.studentId,
    this.studentName,
    this.grNo,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'targetType': targetType,
      'studentId': studentId,
      'studentName': studentName,
      'grNo': grNo,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory NoticeModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return NoticeModel(
      docId: snapshot.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      targetType: data['targetType'] ?? 'all',
      studentId: data['studentId'],
      studentName: data['studentName'],
      grNo: data['grNo'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }
}
