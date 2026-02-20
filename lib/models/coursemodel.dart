import 'package:cloud_firestore/cloud_firestore.dart';

class Coursemodel {
  final String courseId;
  final String courseName;
  // final bool coType;
  Coursemodel({
    required this.courseId,
    required this.courseName,
    // required this.coType,
  });
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId, 'courseName': courseName,
      // 'coType': coType
    };
  }

  factory Coursemodel.fromJson(Map<String, dynamic> json) {
    return Coursemodel(
      courseId: json['courseId'],
      courseName: json['courseName'],
      // coType: json['coType'],
    );
  }
  factory Coursemodel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> coursedata = snapshot.data() as Map<String, dynamic>;
    return Coursemodel(
      courseId: snapshot.id,
      courseName: coursedata['courseName'],
      // coType: coursedata['coType'],
    );
  }
}
