import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:class_leap_flutter/Models/user.dart';
import 'package:firebase_core/firebase_core.dart';

import 'database.dart';


class AuthService {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  //create user object based on FirebaseUser
  User? _userFromFirebaseUser(auth.User? user) {
    if (user != null) {
      return User(uid: user.uid);
    } else {
      return null;
    }
  }

  //auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges()
        .map(_userFromFirebaseUser);
  }

  //sign in anon
  Future signInAnon() async {
    try {
      auth.UserCredential result = await _auth.signInAnonymously();
      auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

//sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      print("Signing in with email and password");
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print("Error signing in with email and password");
      print(e.toString());
      return null;
    }
  }

    /// In lib/Services/auth.dart
    Future registerWithEmailAndPassword(String email, String password, String name, String nim) async {
      try {
        print("Registering with email and password");
        auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        auth.User? user = result.user;
        print("User registered successfully");
        // Update user data in Firestore without the password
        if (user != null) {
          DatabaseService dbService = DatabaseService.getInstance(uid: user.uid);
          await dbService.updateUserData(name, email, nim); // Removed password from parameters
          print("User data updated successfully2");
        }

        return _userFromFirebaseUser(user);
      } catch(e) {
        print(e.toString());
        print("Error registering with email and password");
        return null;
      }
    }

//sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
