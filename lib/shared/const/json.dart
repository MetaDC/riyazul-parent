import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, String> studentData = {};
// void _saveStudentData() {
//   studentData = {
//     'grNo': grNoController.text,
//     'dob': dobController.text,
//     'address': addController.text,
//     'studentName': sNameController.text,
//     'mobile': mobileController.text,
//     'email': emailController.text,
//     'gender': _character == Gender.male ? 'Male' : 'Female',
//     'madrashaName': madreshaNameController.text,
//   };
// }

// final TextEditingController grNoController = TextEditingController();
// final TextEditingController dobController = TextEditingController();
// final TextEditingController addController = TextEditingController();
// final TextEditingController sNameController = TextEditingController();
// final TextEditingController mobileController = TextEditingController();
// final TextEditingController emailController = TextEditingController();
// final TextEditingController genderController = TextEditingController();
// final TextEditingController madreshaNameController = TextEditingController();
// Gender? _character = Gender.male;

List<Map<String, dynamic>> liname = [
  {
    "School level": ['One', 'Two', 'Three', 'Four'],
  },
  {
    "Medium": ['English', 'Gujarati'],
  },
  {
    "Deeniyat class": ['Aalim Class', 'Hifz Class'],
  },
];

FirebaseFirestore firestore = FirebaseFirestore.instance;
bool isLoading = false;

// TextEditingController classNameController = TextEditingController();
// TextEditingController courseController = TextEditingController();
// TextEditingController subNameController = TextEditingController();
// TextEditingController subMarksController = TextEditingController();
// // TextEditingController classController = TextEditingController();
// TextEditingController subController = TextEditingController();
// List<String> tCourseId = [];
// List<String> tClassId = [];
// List<String> tSubId = [];
// TextEditingController tnameController = TextEditingController();
// TextEditingController taddController = TextEditingController();
// TextEditingController tphoneController = TextEditingController();
// List<ClassModel> classModels = [];
// List<Coursemodel> courseModels = [];
// List<String> classesId = [];
// List<SubjectModel> subjects = [];
enum ClassType { school, madresha }

enum Gender { male, female }

class FeeTypes {
  static const sponsored = 'Sponsored';
  static const semiSponsored = 'SemiSponsored';
  static const self = 'Self';
}

List<String> feeTypes = [
  FeeTypes.sponsored,
  FeeTypes.semiSponsored,
  FeeTypes.self,
];

class PaymentMode {
  static const cash = 'Cash';
  static const upi = 'UPI';
  static const cheque = 'Cheque ';
  // static const self = 'Self';
}

List<String> paymentMode = [
  PaymentMode.upi,
  PaymentMode.cash,
  PaymentMode.cheque,
];

class FeeType {
  static const tutionFee = 'Tution Fee';
  static const admission = 'Admission';
  static const bookBag = 'Books & Bag ';
  static const others = 'Others ';
  // static const self = 'Self';
}

List<String> feeType = [
  FeeType.tutionFee,
  FeeType.admission,
  FeeType.bookBag,
  FeeType.others,
];
