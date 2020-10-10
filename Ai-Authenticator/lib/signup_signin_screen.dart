import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication/auth.dart';
import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';

class SignupSigninScreen extends StatefulWidget {
  SignupSigninScreen({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _SignupSigninScreenState();
}

enum FormMode { SIGNIN, SIGNUP }

class MaliciousUserException implements Exception {
  String message() => 'Malicious login! Please Try Later.';
}

class _SignupSigninScreenState extends State<SignupSigninScreen> {
  final _formKey = new GlobalKey<FormState>();
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();
  String _usermail;
  String _userpassword;
  String _errorMessage;

  // Start with Signin form mode

  FormMode _formMode = FormMode.SIGNIN;
  bool _loading;

  // Validate the form before Signing In or Signing up
  bool isValidForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _signinSignup() async {
    // print("Email: " + _usermail);
    // print("password: " + _userpassword);
    setState(() {
      _errorMessage = "";
      _loading = true;
    });
    if (isValidForm()) {
      String userId = "";
      try {
        if (_formMode == FormMode.SIGNIN) {
          var val = await widget.auth.isValidUser(_usermail, _userpassword);
          if (val < 0.20) {
            throw new MaliciousUserException();
          }
          userId = await widget.auth.signIn(_usermail, _userpassword);
        } else {
          userId = await widget.auth.signUp(_usermail, _userpassword);
        }
        setState(() {
          _loading = false;
        });

        if (userId.length > 0 &&
            userId != null &&
            _formMode == FormMode.SIGNIN) {
          widget.onSignedIn();
        }
      } catch (MaliciousUserException) {
        setState(() {
          _loading = false;
          _errorMessage = 'Malicious user detected. Please try again later.';
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _loading = false;
          _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _errorMessage = "";
    _loading = false;
    super.initState();
  }

  void _switchFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _switchFormToSignin() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Firebase Authentication'),
      ),
      body: Stack(
        children: <Widget>[
          _createBody(),
          _createCircularProgress(),
          _createRecaptcha(),
        ],
      ),
    );
  }

  // The Form class is used to group and validate multiple FormFields together.
//  Here, we are using Form to wrap two TextFormFields, one RaisedButton, and one FlatButton together.
  Widget _createCircularProgress() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _createBody() {
    return new Container(
      padding: EdgeInsets.all(16),
      child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _createUserMailInput(),
              _createPasswordInput(),
              _createSigninButton(),
              _createSigninSwitchButton(),
              _createErrorMessage(),
            ],
          )),
    );
  }

  Widget _createRecaptcha() {
    return RecaptchaV2(
      apiKey: "<Your Key>",
      apiSecret: "<Your Key>",
      controller: recaptchaV2Controller,
      onVerifiedError: (err) {
        print(err);
      },
      onVerifiedSuccessfully: (success) {
        setState(() {
          if (success) {
            _signinSignup();
          } else {
            print('Failed to verify!');
          }
        });
      },
    );
  }

  Widget _createErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: new TextStyle(
            fontSize: 16,
            color: Colors.red,
            height: 1,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0,
      );
    }
  }

  Widget _createUserMailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _usermail = value.trim(),
      ),
    );
  }

// We will use this enumeration for the button that would let the user both sign in and sign up.
// It will help us easily switch between the two modes.
// Enumeration is a set of identifiers that is used for denoting constant values.

  Widget _createPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty ? "Password can\'t be empty" : null,
        onSaved: (value) => _userpassword = value.trim(),
      ),
    );
  }

  Widget _createSigninSwitchButton() {
    return new FlatButton(
      child: _formMode == FormMode.SIGNIN
          ? new Text('Create an Account',
              style: new TextStyle(fontSize: 18, fontWeight: FontWeight.w300))
          : new Text(
              'Have an Account? Sign in',
              style: new TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
      onPressed: _formMode == FormMode.SIGNIN
          ? _switchFormToSignUp
          : _switchFormToSignin,
    );
  }

  Widget _createSigninButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 45, 0, 0),
      child: SizedBox(
        height: 40,
        child: new RaisedButton(
          elevation: 5,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
          color: Colors.blue,
          child: _formMode == FormMode.SIGNIN
              ? new Text('SignIn',
                  style: new TextStyle(fontSize: 20, color: Colors.white))
              : new Text(
                  'Create Account',
                  style: new TextStyle(fontSize: 20, color: Colors.white),
                ),
          onPressed: recaptchaV2Controller.show,
        ),
      ),
    );
  }
}
