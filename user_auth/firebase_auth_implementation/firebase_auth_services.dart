// ignore_for_file: avoid_print, prefer_final_fields

import 'package:firebase_auth/firebase_auth.dart';

import '../../../global/common/toast.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'Το email χρησιμοποιείται ήδη!');
      }else if (e.code == 'weak-password'){
        showToast(message: 'Αδύναμος κωδικός πρόσβασης');
      }else {
        showToast(message: 'Σφάλμα : ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        showToast(message: 'Λάθος email ή κωδικός πρόσβασης.');
      } else {
        showToast(message: 'Σφάλμα : ${e.code}');
      }
    }
    return null;
  }
}
