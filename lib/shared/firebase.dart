import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FBAuth {
  static final auth = FirebaseAuth.instance;
}

class FBFireStore {
  static final fb = FirebaseFirestore.instance;
  static final subjects = fb.collection('subjects');
  static final students = fb.collection('students');
  static final classes = fb.collection('classes');
  static final teachers = fb.collection('teachers');
  static final courses = fb.collection('course');
  static final feedetails = fb.collection('feedetails');
  static final feetranscationdetails = fb.collection('feetranscationdetails');
  static final results = fb.collection('results');
  static final attendance = fb.collection('attendance');
  static final settings = fb.collection('settings').doc("sets");
  static final totalDays = fb.collection('settings').doc("totaldays");
  static final studentNotes = fb.collection('studentNotes');
  static final notices = fb.collection('notices');
  static final notifications = fb.collection('notifications');
}

class FBStorage {
  static final fbstore = FirebaseStorage.instance;
  // static final products = fbstore.ref().child('products');
  // static final banners = fbstore.ref().child('banners');
  // static final category = fbstore.ref().child('category');
}

class FBFunctions {
  static final ff = FirebaseFunctions.instance;
}
