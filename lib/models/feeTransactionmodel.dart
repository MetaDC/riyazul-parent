import 'package:cloud_firestore/cloud_firestore.dart';

class Feetransactionmodel {
  final String docId;
  final String studId;
  final DateTime startDate;
  final DateTime endDate;
  final String totalAmt;
  final String acedemicYear;
  final String receivedAmt;
  final DateTime receivedDate;
  final String receiptNo;
  final String paymentMode;
  final String feeType;
  final List<Map<String, dynamic>> feeDetails;
  final String remarks;

  Feetransactionmodel({
    required this.docId,
    required this.studId,
    required this.startDate,
    required this.endDate,
    required this.totalAmt,
    required this.acedemicYear,
    required this.receivedAmt,
    required this.receivedDate,
    required this.receiptNo,
    required this.paymentMode,
    required this.feeType,
    required this.feeDetails,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'studId': studId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalAmt': totalAmt,
      'acedemicYear': acedemicYear,
      'receivedAmt': receivedAmt,
      'receivedDate': receivedDate.toIso8601String(),
      'receiptNo': receiptNo,
      'paymentMode': paymentMode,
      'feeDetails': feeDetails,
      'feeType': feeType,

      'remarks': remarks,
    };
  }

  factory Feetransactionmodel.fromJson(Map<String, dynamic> json) {
    return Feetransactionmodel(
      docId: json['docId'] ?? '',
      studId: json['studId'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalAmt: json['totalAmt'] ?? '',
      acedemicYear: json['acedemicYear'] ?? '',
      receivedAmt: json['receivedAmt'] ?? '',
      receivedDate: DateTime.parse(json['receivedDate']),
      receiptNo: json['receiptNo'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      feeDetails: List<Map<String, dynamic>>.from(json['feeDetails'] ?? []),
      feeType: json['feeType'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  factory Feetransactionmodel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Feetransactionmodel(
      docId: snapshot.id,
      studId: data['studId'] ?? '',
      startDate: data['startDate'] is Timestamp
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] is Timestamp
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      totalAmt: data['totalAmt']?.toString() ?? '',
      receivedAmt: data['receivedAmt']?.toString() ?? '',
      acedemicYear: data['acedemicYear']?.toString() ?? '',
      receivedDate: data['receivedDate'] is Timestamp
          ? (data['receivedDate'] as Timestamp).toDate()
          : DateTime.now(),
      receiptNo: data['receiptNo']?.toString() ?? '',
      paymentMode: data['paymentMode']?.toString() ?? '',
      feeDetails:
          (data['feeDetails'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      feeType: data['feeType']?.toString() ?? '',
      remarks: data['remarks']?.toString() ?? '',
    );
  }
}
