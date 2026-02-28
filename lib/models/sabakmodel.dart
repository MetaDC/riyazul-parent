import 'package:cloud_firestore/cloud_firestore.dart';

class Sabakmodel {
  final String docId;
  final String sabakId;
  final String studentId;
  final String ustadId;
  final String paraNo;
  final String sabakText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sabakmodel({
    required this.docId,
    required this.sabakId,
    required this.studentId,
    required this.ustadId,
    required this.paraNo,
    required this.sabakText,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sabakId': sabakId,
      'studentId': studentId,
      'ustadId': ustadId,
      'paraNo': paraNo,
      'sabakText': sabakText,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Sabakmodel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Sabakmodel(
      docId: snapshot.id,
      sabakId: snapshot.id,
      studentId:
          data['studentId'] ??
          data['studId'] ??
          data['grNO'] ??
          data['grNo'] ??
          '',
      ustadId: data['ustadId'] ?? data['teacherId'] ?? '',
      paraNo: data['paraNo']?.toString() ?? '',
      sabakText: data['sabakText'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
