import 'package:firebase_authentication/auth.dart';
import 'package:firebase_authentication/signup_signin_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_authentication/home_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({this.auth});

  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _MainScreenState();
}

enum AuthStatus {
  NOT_SIGNED_IN,
  SIGNED_IN,
}

class _MainScreenState extends State<MainScreen> {
  AuthStatus authStatus = AuthStatus.NOT_SIGNED_IN;
  String _userId = '';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (authStatus == AuthStatus.NOT_SIGNED_IN) {
      return new SignupSigninScreen(
        auth: widget.auth,
        onSignedIn: _onSignedIn,
      );
    } else {
      return new HomeScreen(
          userId: _userId, auth: widget.auth, onSignedOut: _onSignedOut);
    }
  }

//establish whether the user was logged in by overriding the initState() method:
  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user;
        }
        authStatus =
            user == null ? AuthStatus.NOT_SIGNED_IN : AuthStatus.SIGNED_IN;
      });
    });
  }

// Now, we will define two other methods, onSignIn()
// and onSignOut(), to ensure that the authentication status is stored correctly
// in the variable and the user interface is updated accordingly:

// The _onSignedIn() method checks whether a user was already signed in and
//sets authStatus to AuthStatus.SIGNED_IN.. The _onSignedOut() method checks
// whether the user was signed out and sets authStatus to AuthStatus.SIGNED_OUT.

  void _onSignedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user;
      });
    });

    setState(() {
      authStatus = AuthStatus.SIGNED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_SIGNED_IN;
      _userId = "";
    });
  }
}
