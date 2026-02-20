import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:riyazul_parent/shared/firebase.dart';

Future<String> getAndIncrementReceiptCounter() async {
  final fb = FirebaseFirestore.instance;
  final receiptCounterRef = FBFireStore.settings;

  return fb.runTransaction((transaction) async {
    final snapshot = await transaction.get(receiptCounterRef);
    int current = 1;

    if (snapshot.exists && snapshot.data()?['recepitNo'] != null) {
      current = snapshot.data()?['recepitNo'] as int;
    }

    final newReceipt = (current + 1).toString().padLeft(4, '0');
    transaction.set(receiptCounterRef, {'recepitNo': current + 1});
    return newReceipt;
  });
}

Future<void> resetReceiptCounter() async {
  final receiptCounterRef = FBFireStore.settings;
  await receiptCounterRef.set({'recepitNo': -1});
}

extension MetaWid on DateTime {
  String goodDate() {
    try {
      return DateFormat.yMMMM().format(this);
    } catch (e) {
      return toString().split(" ").first;
    }
  }

  String goodDayDate() {
    try {
      return DateFormat.yMMMMd().format(this);
    } catch (e) {
      return toString().split(" ").first;
    }
  }

  String convertToDDMMYY() {
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(this);
  }

  String goodTime() {
    try {
      return DateFormat('hh:mm a').format(this);
    } catch (e) {
      return toString().split(" ").first;
    }
  }

  String monthYear() {
    try {
      return DateFormat('MMM yyyy').format(this);
    } catch (e) {
      return toString().split(" ").first;
    }
  }
}

String getAcademicYearFromDate(DateTime date) {
  if (date.month >= 6) {
    // June to December
    return "${date.year}-${date.year + 1}";
  } else {
    // January to May
    return "${date.year - 1}-${date.year}";
  }
}
