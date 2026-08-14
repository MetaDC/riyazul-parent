import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNoteModel {
  final String docId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String para;
  final String remarks;
  final String imageUrl;

  StudentNoteModel({
    required this.docId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.para,
    required this.remarks,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'date': Timestamp.fromDate(date),
      'para': para,
      'remarks': remarks,
      'imageUrl': imageUrl,
    };
  }

  factory StudentNoteModel.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return StudentNoteModel(
      docId: doc.id,
      studentId: data['studentId']?.toString() ?? '',
      studentName: data['studentName']?.toString() ?? '',
      date: parsedDate,
      para: data['para']?.toString() ?? '',
      remarks: data['remarks']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
    );
  }
}
