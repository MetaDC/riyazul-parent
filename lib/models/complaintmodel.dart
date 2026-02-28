import 'package:cloud_firestore/cloud_firestore.dart';

class Complaintmodel {
  final String complaintId;
  final String teacherId;
  final String studentId;
  final String title;
  final String description;
  final String status; // 'Pending' | 'Resolved'
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaintmodel({
    required this.complaintId,
    required this.teacherId,
    required this.studentId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'teacherId': teacherId,
      'studentId': studentId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Complaintmodel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Complaintmodel(
      complaintId: snapshot.id,
      studentId: data['studentId'] ?? data['studId'] ?? '',
      teacherId: data['teacherId'] ?? data['ustadId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
