import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

enum UserLoginState {
  userLogged,
  userNotLogged,
}

class FirebaseService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  UserLoginState _state = UserLoginState.userNotLogged;

  bool _isOverlay = false;

  bool get isOverlay => _isOverlay;

  set isOverlay(bool isOverlay) {
    _isOverlay = isOverlay;
    notifyListeners();
  }



  UserLoginState get state => _state;

  set state(UserLoginState value) {
    _state = value;
    notifyListeners();
  }

  FirebaseService() {
    _firebaseAuth.authStateChanges().listen(_authStateChanged);
  }

String _errorTextMessage = "";

  String get errorTextMessage => _errorTextMessage;

  set errorTextMessage(String errorTextMessage) {
    _errorTextMessage = errorTextMessage;
    notifyListeners();
  }

  void _authStateChanged(User? user) {
    if (user != null) {
      state = UserLoginState.userLogged;
    } else {
      state = UserLoginState.userNotLogged;
    }
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
        _firebaseFirestore
            .collection('Users')
            .doc(user.user?.uid)
            .set({'id': user.user?.uid, 'email': email, 'password': password}).then((_){
              _firebaseFirestore.collection('Users').doc(user.user?.uid).collection('Gelir').add({'test' : 0});
              _firebaseFirestore.collection('Users').doc(user.user?.uid).collection('Gider').add({'test' : 0});
              _firebaseFirestore.collection('Users').doc(user.user?.uid).collection('Cariler').doc('cariler').set({'cariler' : FieldValue.arrayUnion(['Sigara','Yemek'])});
            });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        errorTextMessage = "Şifreniz en az 6 haneli olmalıdır.";
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        errorTextMessage = "Bu e-posta adresi zaten kayıtlı. Mevcut üyeliğiniz varsa lütfen giriş yapın.";
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorTextMessage = "Kullanıcı bulunamadı.";
        print('No user found for that email.');
        print(errorTextMessage);
      } else if (e.code == 'wrong-password') {
        errorTextMessage = "Şifre yanlış.";
        print('Wrong password provided for that user.');
        print(errorTextMessage);
      }
    }

  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
