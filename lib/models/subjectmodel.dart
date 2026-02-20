import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String subId;
  final String subName;
  final String subMarks;
  final bool isActive;
  final bool isOptional;

  SubjectModel({
    required this.subId,
    required this.subName,
    required this.subMarks,
    required this.isActive,
    required this.isOptional,
  });

  Map<String, dynamic> toMap() {
    return {
      'subName': subName,
      'subMarks': subMarks,
      'isActive': isActive,
      'isOptional': isOptional,
    };
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subId: json['subId'],
      subName: json['subName'],
      subMarks: json['subMarks'],
      isActive: json['isActive'] ?? true,
      isOptional: json['isOptional'] ?? false,
    );
  }

  factory SubjectModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return SubjectModel(
      subId: snapshot.id,
      subName: data['subName'],
      subMarks: data['subMarks'],
      isActive: data['isActive'] ?? true,
      isOptional: data['isOptional'] ?? false,
    );
  }
}
