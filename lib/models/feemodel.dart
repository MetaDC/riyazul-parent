import 'package:cloud_firestore/cloud_firestore.dart';

class Feemodel {
  final String feeId;
  final String title;
  final String amount;

  Feemodel({required this.feeId, required this.title, required this.amount});
  Map<String, dynamic> toMap() {
    return {'feeId': feeId, 'title': title, 'amount': amount};
  }

  factory Feemodel.fromJson(Map<String, dynamic> json) {
    return Feemodel(
      feeId: json['feeId'],
      title: json['title'],
      amount: json['amount'],
    );
  }
  factory Feemodel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> feedata = snapshot.data() as Map<String, dynamic>;
    return Feemodel(
      feeId: snapshot.id,
      title: feedata['title'],
      amount: feedata['amount'],
    );
  }
}

