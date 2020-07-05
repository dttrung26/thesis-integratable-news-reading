import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/user.dart';
import '../../widgets/login_animation.dart';

class VerifyCode extends StatefulWidget {
  final bool fromCart;
  final String phoneNumber;
  final String verId;

  VerifyCode({this.fromCart = false, this.verId, this.phoneNumber});

  @override
  _LoginSMSState createState() => _LoginSMSState();
}

class _LoginSMSState extends State<VerifyCode> with TickerProviderStateMixin {
  //final changeNotifier = StreamController<Functions>();
  AnimationController _loginButtonController;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool hasError = false;
  String currentText = "";
  var onTapRecognizer;

  @override
  void initState() {
    super.initState();

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };

    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {}
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {}
  }

  void _welcomeMessage(user, context) {
    if (widget.fromCart) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      final snackBar =
          SnackBar(content: Text(S.of(context).welcome + ' ${user.name} !'));
      scaffoldKey.currentState.showSnackBar(snackBar);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('Warning: $message'),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _loginSMS(smsCode, context) async {
    _playAnimation();
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: widget.verId,
        smsCode: smsCode,
      );

      final FirebaseUser user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (user != null) {
        Provider.of<UserModel>(context, listen: false).loginFirebaseSMS(
          phoneNumber: user.phoneNumber,
          success: (user) {
            _stopAnimation();
            _welcomeMessage(user, context);
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message, context);
          },
        );
      } else {
        _stopAnimation();
        _failMessage(S.of(context).invalidSMSCode, context);
      }
    } catch (e) {
      _stopAnimation();
      _failMessage(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColorLight,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 40.0,
                        child: Image.asset('assets/images/logo.png')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Phone Number Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: RichText(
                text: TextSpan(
                    text: "Enter the code sent to ",
                    children: [
                      TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: PinCodeTextField(
                  length: 6,
                  obsecureText: false,
                  autoFocus: true,
                  animationType: AnimationType.fade,
                  shape: PinCodeFieldShape.underline,
                  animationDuration: Duration(milliseconds: 300),
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  onChanged: (value) {
                    if (value != null && value.length == 6) {
                      _loginSMS(value, context);
                    }
                  },
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              // error showing widget
              child: Text(
                hasError ? "*Please fill up all the cells properly" : "",
                style: TextStyle(color: Colors.red.shade300, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "Didn't receive the code? ",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  children: [
                    TextSpan(
                        text: " RESEND",
                        recognizer: onTapRecognizer,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))
                  ]),
            ),
            SizedBox(
              height: 14,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
              child: StaggerAnimation(
                titleButton: S.of(context).verifySMSCode,
                buttonController: _loginButtonController.view,
                onTap: () {
                  if (!isLoading) {
                    //changeNotifier.add(Functions.submit);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}
