import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNoteModel {
  final String docId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String para;
  final String remarks;

  StudentNoteModel({
    required this.docId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.para,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'date': Timestamp.fromDate(date),
      'para': para,
      'remarks': remarks,
    };
  }

  factory StudentNoteModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentNoteModel(
      docId: doc.id,
      studentId: data['studentId'],
      studentName: data['studentName'],
      date: (data['date'] as Timestamp).toDate(),
      para: data['para'],
      remarks: data['remarks'],
    );
  }
}
