import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// create an abstract class, BaseAuth, which lists all the authentication methods
// and acts a middle layer between the UI components and the authentication methods:

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<String> getCurrentUser();
  Future<void> signOut();
  Future<double> isValidUser(String email, String password);
}

class Auth implements BaseAuth {
  //Create an instance of FirebaseAuth:
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Implement SignIn Method
  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<double> isValidUser(String email, String password) async {
    final response = await http.Client()
        .get('http://34.67.160.232:8000/login?user=$email&password=$password');
    var jsonResponse = json.decode(response.body);
    var val = '${jsonResponse["result"]}';
    double result = double.parse(val);
    return result;
  }
}
