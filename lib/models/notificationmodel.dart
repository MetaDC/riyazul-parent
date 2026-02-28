import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String docId;
  final String title;
  final String body;
  final String type; // 'fee' | 'result' | 'notice' | 'sabak' | 'complaint'
  final String targetType; // 'all' | 'specific'
  final String?
  studentId; // null = all students, filled = specific student only
  final DateTime createdAt;
  final bool isRead;
  final List<String> readBy;

  NotificationModel({
    required this.docId,
    required this.title,
    required this.body,
    required this.type,
    required this.targetType,
    this.studentId,
    required this.createdAt,
    required this.isRead,
    this.readBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'targetType': targetType,
      'studentId': studentId, // null for 'all'
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'readBy': readBy,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      docId: docId,
      title: title,
      body: body,
      type: type,
      targetType: targetType,
      studentId: studentId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      readBy: readBy,
    );
  }

  factory NotificationModel.fromSnapshot(
    DocumentSnapshot snapshot, {
    String? currentStudentId,
  }) {
    final data = snapshot.data() as Map<String, dynamic>;
    final targetType = data['targetType'] ?? 'all';
    final readByList = List<String>.from(data['readBy'] ?? []);

    // Determine isRead
    bool isRead = false;
    if (targetType == 'all' && currentStudentId != null) {
      isRead = readByList.contains(currentStudentId);
    } else {
      isRead = data['isRead'] ?? false;
    }

    return NotificationModel(
      docId: snapshot.id,
      title: data['title'] ?? '',
      body: data['body'] ?? data['message'] ?? '',
      type: data['type'] ?? 'notice',
      targetType: targetType,
      studentId: data['studentId'] ?? data['studId'], // can be null
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: isRead,
      readBy: readByList,
    );
  }
}
