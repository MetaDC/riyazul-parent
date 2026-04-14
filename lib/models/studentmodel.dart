import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Firestore Timestamp DOB to a UTC-midnight DateTime.
///
/// DOBs are stored as midnight in IST (UTC+5:30), so the raw UTC value is
/// the *previous* day at 18:30. On a device in UTC-5 (USA) that becomes
/// 13:30 the previous day — i.e. the wrong calendar date.
///
/// Fix: shift by +12 hours in UTC before reading the date components.
/// Since the maximum timezone offset is ±14 h, a "midnight" timestamp stored
/// in *any* timezone will land within ±14 h of true midnight UTC.  Adding
/// 12 h snaps it unambiguously to the correct calendar day regardless of the
/// reader's locale.
///   IST midnight → UTC 18:30 → +12 h → next-day 06:30 → correct date ✓
///   UTC midnight → UTC 00:00 → +12 h → same-day  12:00 → correct date ✓
///   UTC-5 midnight → UTC 05:00 → +12 h → same-day 17:00 → correct date ✓
DateTime _dobFromTimestamp(Timestamp? ts) {
  if (ts == null) return DateTime.utc(2000);
  final utcSnapped = ts.toDate().toUtc().add(const Duration(hours: 12));
  return DateTime.utc(utcSnapped.year, utcSnapped.month, utcSnapped.day);
}

class Studentmodel {
  final String docId;
  final String grNO;
  final String name;
  final String addressHouseNo;
  final String addressHouseArea;
  final DateTime dob;
  final String phoneNumber;
  final String? email;
  final bool isMale;
  final String? prevSchoolName;
  final String? prevSchoolClass;
  final String? prevMadrasaName;
  final String? prevDeeniyatDetail;
  final String? currentSchoolStd;
  final String currentDeeniyat;
  // final String feeType;
  final DateTime addmissonDate;
  final DateTime createdAt;
  final String? feeRemarks;
  final String feeType;
  final bool isActive;
  final DateTime? deactivatedAt;
  final bool isInstalledAppUser;
  final DateTime? lastLoginDatetime;
  List<String>? loginDeviceIds;

  Studentmodel({
    required this.docId,
    required this.grNO,
    required this.addressHouseNo,
    required this.addressHouseArea,
    required this.name,
    required this.dob,
    required this.phoneNumber,
    required this.email,
    required this.isMale,
    required this.prevSchoolName,
    required this.prevSchoolClass,
    required this.prevMadrasaName,
    required this.prevDeeniyatDetail,
    required this.currentSchoolStd,
    required this.currentDeeniyat,
    // required this.feeType,
    required this.addmissonDate,
    required this.createdAt,
    required this.feeRemarks,
    required this.feeType,
    required this.isActive,
    this.deactivatedAt,
    this.isInstalledAppUser = false,
    this.lastLoginDatetime,
    this.loginDeviceIds,
  });
  Map<String, dynamic> toMap() {
    return {
      'studId': docId,
      'grNO': grNO,
      'name': name,
      'addressHouseNo': addressHouseNo,
      'addressHouseArea': addressHouseArea,
      'dob': Timestamp.fromDate(dob),
      'phoneNumber': phoneNumber,
      'email': email,
      'isMale': isMale,
      'prevSchoolName': prevSchoolName,
      'prevSchoolClass': prevSchoolClass,
      'prevMadrasaName': prevMadrasaName,
      'prevDeeniyatDetail': prevDeeniyatDetail,
      'currentSchoolStd': currentSchoolStd,
      'currentDeeniyat': currentDeeniyat,
      // 'feeType': feeType,
      'addmissonDate': Timestamp.fromDate(addmissonDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'feeRemarks': feeRemarks,
      'feeType': feeType,
      'isActive': isActive,
      'deactivatedAt': deactivatedAt != null
          ? Timestamp.fromDate(deactivatedAt!)
          : null,
      'isInstalledAppUser': isInstalledAppUser,
      'lastLoginDatetime': lastLoginDatetime != null
          ? Timestamp.fromDate(lastLoginDatetime!)
          : null,
      'loginDeviceIds': loginDeviceIds,
    };
  }

  factory Studentmodel.fromJson(Map<String, dynamic> json) {
    return Studentmodel(
      docId: json['studId'],
      grNO: json['grNO'],
      name: json['name'],
      addressHouseNo: json['addressHouseNo'],
      addressHouseArea: json['addressHouseArea'],
      dob: _dobFromTimestamp(json['dob'] as Timestamp?),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      isMale: json['isMale'] ?? false,
      prevSchoolName: json['prevSchoolName'],
      prevSchoolClass: json['prevSchoolClass'],
      prevMadrasaName: json['prevMadrasaName'],
      prevDeeniyatDetail: json['prevDeeniyatDetail'],
      currentSchoolStd: json['currentSchoolStd'],
      currentDeeniyat: json['currentDeeniyat'],
      // feeType: json['feeType'],
      addmissonDate: (json['addmissonDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      feeRemarks: json['feeRemarks'] ?? '',
      feeType: json['feeType'],
      isActive: json['isActive'] ?? true,
      deactivatedAt: json['deactivatedAt'] != null
          ? (json['deactivatedAt'] as Timestamp).toDate()
          : null,
      isInstalledAppUser: json['isInstalledAppUser'] ?? false,
      lastLoginDatetime: json['lastLoginDatetime'] != null
          ? (json['lastLoginDatetime'] as Timestamp).toDate()
          : null,
      loginDeviceIds: json['loginDeviceIds'] != null
          ? List<String>.from(json['loginDeviceIds'])
          : null,
    );
  }

  factory Studentmodel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Studentmodel(
      docId: snapshot.id,
      grNO: data['grNO'] ?? '',
      name: data['name'] ?? '',
      addressHouseNo: data['addressHouseNo'] ?? '',
      addressHouseArea: data['addressHouseArea'] ?? '',
      dob: _dobFromTimestamp(data['dob'] as Timestamp?),
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'],
      isMale: data['isMale'] ?? false,

      // 🔥 THIS LINE FIXES THE CRASH
      isActive: data['isActive'] ?? true,

      prevSchoolName: data['prevSchoolName'],
      prevSchoolClass: data['prevSchoolClass'],
      prevMadrasaName: data['prevMadrasaName'],
      prevDeeniyatDetail: data['prevDeeniyatDetail'],
      currentSchoolStd: data['currentSchoolStd'],
      currentDeeniyat: data['currentDeeniyat'] ?? '',
      addmissonDate:
          (data['addmissonDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      feeRemarks: data['feeRemarks'] ?? '',
      feeType: data['feeType'] ?? 'monthly',
      deactivatedAt: data['deactivatedAt'] != null
          ? (data['deactivatedAt'] as Timestamp).toDate()
          : null,
      isInstalledAppUser: data['isInstalledAppUser'] ?? false,
      lastLoginDatetime: data['lastLoginDatetime'] != null
          ? (data['lastLoginDatetime'] as Timestamp).toDate()
          : null,
      loginDeviceIds: data['loginDeviceIds'] != null
          ? List<String>.from(data['loginDeviceIds'])
          : null,
    );
  }

  Studentmodel copyWith({
    bool? isActive,
    DateTime? deactivatedAt,
    bool? isInstalledAppUser,
    DateTime? lastLoginDatetime,
    String? loginDeviceId,
  }) {
    return Studentmodel(
      docId: docId,
      grNO: grNO,
      name: name,
      addressHouseNo: addressHouseNo,
      addressHouseArea: addressHouseArea,
      dob: dob,
      phoneNumber: phoneNumber,
      email: email,
      isMale: isMale,
      prevSchoolName: prevSchoolName,
      prevSchoolClass: prevSchoolClass,
      prevMadrasaName: prevMadrasaName,
      prevDeeniyatDetail: prevDeeniyatDetail,
      currentSchoolStd: currentSchoolStd,
      currentDeeniyat: currentDeeniyat,
      addmissonDate: addmissonDate,
      createdAt: createdAt,
      feeRemarks: feeRemarks,
      feeType: feeType,
      isActive: isActive ?? this.isActive,
      deactivatedAt: deactivatedAt,
      isInstalledAppUser: isInstalledAppUser ?? this.isInstalledAppUser,
      lastLoginDatetime: lastLoginDatetime ?? this.lastLoginDatetime,
      loginDeviceIds: loginDeviceIds ?? this.loginDeviceIds,
    );
  }
}
