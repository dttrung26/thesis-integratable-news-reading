import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/user.dart';
import '../../widgets/login_animation.dart';
import 'verify.dart';

class LoginSMS extends StatefulWidget {
  final bool fromCart;

  LoginSMS({this.fromCart = false});

  @override
  _LoginSMSState createState() => _LoginSMSState();
}

class _LoginSMSState extends State<LoginSMS> with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  String phoneNumber;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    if (internationalizedPhoneNumber != "") {
      phoneNumber = internationalizedPhoneNumber;
    } else {
      phoneNumber = null;
    }
  }

  _loginSMS(context) async {
    if (phoneNumber == null) {
      var snackBar = SnackBar(content: Text(S.of(context).pleaseInput));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      _playAnimation();
      final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
        _stopAnimation();
      };

      final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
        _stopAnimation();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyCode(
                  fromCart: widget.fromCart,
                  verId: verId,
                  phoneNumber: phoneNumber)),
        );
      };

      final PhoneVerificationCompleted verifiedSuccess =
          (AuthCredential phoneAuthCredential) {
        print('verified');
      };

      final PhoneVerificationFailed veriFailed = (AuthException exception) {
        _stopAnimation();
        _failMessage(exception.message, context);
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          codeAutoRetrievalTimeout: autoRetrieve,
          codeSent: smsCodeSent,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verifiedSuccess,
          verificationFailed: veriFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop())
                Navigator.of(context).pop();
              else
                Navigator.of(context).pushNamed('/home');
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(children: [
            ListenableProvider.value(
              value: Provider.of<UserModel>(context, listen: false),
              child: Consumer<UserModel>(builder: (context, model, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 80.0),
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
                      const SizedBox(height: 120.0),
                      InternationalPhoneInput(
                          onPhoneNumberChange: onPhoneNumberChange,
                          initialSelection:
                              kAdvanceConfig["DefaultPhoneISOCode"]),
                      SizedBox(
                        height: 60.0,
                      ),
                      StaggerAnimation(
                        titleButton: S.of(context).sendSMSCode,
                        buttonController: _loginButtonController.view,
                        onTap: () {
                          if (!isLoading) {
                            _loginSMS(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ]),
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
