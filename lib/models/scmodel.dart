// import 'package:cloud_firestore/cloud_firestore.dart';

// class Scmodel {
//   final String scId;
//   final String studentId;
//   final String courseId;
//   final String classID;
//   final String feeId;

//   Scmodel({
//     required this.scId,
//     required this.studentId,
//     required this.courseId,
//     required this.classID,
//     required this.feeId,
//   });
//   Map<String, dynamic> toMap() {
//     return {
//       'scId': scId,
//       'studentId': studentId,
//       'courseId': courseId,
//       'classID': classID,
//       'feeId': feeId,
//     };
//   }

//   factory Scmodel.fromJson(Map<String, dynamic> json) {
//     return Scmodel(
//       scId: json['scId'],
//       studentId: json['studentId'],
//       courseId: json['courseId'],
//       classID: json['classID'],
//       feeId: json['feeId'],
//     );
//   }
//   factory Scmodel.fromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> scdata = snapshot.data() as Map<String, dynamic>;
//     return Scmodel(
//       scId: scdata['scId'],
//       studentId: scdata['studentId'],
//       courseId: scdata['courseId'],
//       classID: scdata['classID'],
//       feeId: scdata['feeId'],
//     );
//   }
// }
