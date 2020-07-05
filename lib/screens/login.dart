import 'package:after_layout/after_layout.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/app.dart';
import '../models/user.dart';
import '../screens/login_sms/index.dart';
import '../widgets/login_animation.dart';
import '../widgets/webview.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  final bool fromCart;

  LoginScreen({this.fromCart = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen>
    with TickerProviderStateMixin, AfterLayoutMixin {
  AnimationController _loginButtonController;
  String username, password;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var parentContext;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isAvailableApple = false;

  @override
  void initState() {
    super.initState();
    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    try {
      isAvailableApple = await AppleSignIn.isAvailable();
      setState(() {});
    } catch (e) {}
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
      Navigator.of(context).pop(user);
    } else {
      final snackBar =
          SnackBar(content: Text(S.of(context).welcome + ' ${user.name} !'));
      Scaffold.of(context).showSnackBar(snackBar);

      Navigator.of(context).pushReplacementNamed('/home');
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

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  _loginFacebook(context) async {
    //showLoading();
    _playAnimation();
    Provider.of<UserModel>(context, listen: false).loginFB(
      success: (user) {
        //hideLoading();
        _stopAnimation();
        _welcomeMessage(user, context);
      },
      fail: (message) {
        //hideLoading();
        _stopAnimation();
        _failMessage(message, context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final appModel = Provider.of<AppModel>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    String forgetPasswordUrl = serverConfig['forgetPassword'];

    Future launchForgetPassworldURL(String url) async {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                WebView(url: url, title: 'Reset Password'),
            fullscreenDialog: true,
          ));

//      if (await canLaunch(url)) {
//        await launch(url, forceSafariVC: true, forceWebView: true);
//      } else {}
    }

    _login(context) async {
      if (username == null || password == null) {
        var snackBar = SnackBar(content: Text(S.of(context).pleaseInput));
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        _playAnimation();
        Provider.of<UserModel>(context, listen: false).login(
          username: username.trim(),
          password: password.trim(),
          success: (user) {
            _auth
                .signInWithEmailAndPassword(email: username, password: password)
                .catchError((onError) {
              if (onError.code == 'ERROR_USER_NOT_FOUND')
                _auth
                    .createUserWithEmailAndPassword(
                        email: username, password: password)
                    .then((_) {
                  _auth.signInWithEmailAndPassword(
                      email: username, password: password);
                });
            });
            _stopAnimation();
            _welcomeMessage(user, context);
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message, context);
          },
        );
      }
    }

    _loginSMS(context) async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginSMS()),
      );
//      showLoading();
//      Provider.of<UserModel>(context).loginSMS(
//        success: (user){
//          hideLoading();
//          _welcomeMessage(user, context);
//        },
//        fail: (message){
//          hideLoading();
//          _failMessage(message, context);
//        },
//      );
    }

    _loginGoogle(context) async {
      _playAnimation();
      Provider.of<UserModel>(context, listen: false).loginGoogle(
        success: (user) {
          //hideLoading();
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          //hideLoading();
          _stopAnimation();
          _failMessage(message, context);
        },
      );
    }

    _loginApple(context) async {
      try {
        final AuthorizationResult result = await AppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]);

        switch (result.status) {
          case AuthorizationStatus.authorized:
            {
              final fullName = result.credential.fullName.givenName +
                  " " +
                  result.credential.fullName.familyName;
              _playAnimation();
              Provider.of<UserModel>(context, listen: false).loginApple(
                email: result.credential.email,
                fullName: fullName,
                success: (user) {
                  _stopAnimation();
                  _welcomeMessage(user, context);
                },
                fail: (message) {
                  _stopAnimation();
                  _failMessage(message, context);
                },
              );
            }

            break;

          case AuthorizationStatus.error:
            print("Sign in failed: ${result.error.localizedDescription}");
            break;

          case AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
        }
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                })
            : Container(),
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
                  child: Container(
                    width: screenSize.width,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: screenSize.width /
                            (2 / (screenSize.height / screenSize.width)),
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
                                        child: Image.asset(
                                            'assets/images/logo.png')),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 120.0),

                            TextField(
                                controller: _usernameController,
                                onChanged: (value) => username = value,
                                decoration: InputDecoration(
                                  labelText: S.of(parentContext).username,
                                )),

                            const SizedBox(height: 12.0),
                            Stack(children: <Widget>[
                              TextField(
                                onChanged: (value) => password = value,
                                obscureText: true,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: S.of(parentContext).password,
                                ),
                              ),
                              Positioned(
                                right: appModel.locale == "ar" ? null : 4,
                                left: appModel.locale == "ar" ? 4 : null,
                                bottom: 12,
                                child: InkWell(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 15, top: 8, bottom: 8),
                                    child: Text(
                                      " " + S.of(context).reset,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  onTap: () {
                                    launchForgetPassworldURL(forgetPasswordUrl);
                                  },
                                ),
                              )
                            ]),
                            SizedBox(
                              height: 60.0,
                            ),
                            StaggerAnimation(
                              titleButton: S.of(context).signInWithEmail,
                              buttonController: _loginButtonController.view,
                              onTap: () {
                                if (!isLoading) {
                                  _login(context);
                                }
                              },
                            ),
//                      SignInButtonBuilder(
//                        text: S.of(context).signInWithEmail,
//                        icon: Icons.email,
//                        onPressed: () {
//                          _login(context);
//                        },
//                        padding: EdgeInsets.only(top: 10, bottom: 10),
//                        elevation: 0,
//                        backgroundColor: Theme.of(context).primaryColor,
//                      ),
                            SizedBox(
                              height: 10.0,
                            ),

                            Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  SizedBox(
                                      height: 60.0,
                                      width: 200.0,
                                      child:
                                          Divider(color: Colors.grey.shade300)),
                                  Container(
                                      height: 30,
                                      width: 40,
                                      color: Colors.white),
                                  Text(S.of(context).or,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400))
                                ]),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RawMaterialButton(
                                  onPressed: () => _loginFacebook(context),
                                  child: Icon(
                                    FontAwesomeIcons.facebookF,
                                    color: Color(0xFF4267B2),
                                    size: 24.0,
                                  ),
                                  shape: CircleBorder(),
                                  elevation: 0.4,
                                  fillColor: Colors.grey.shade50,
                                  padding: const EdgeInsets.all(15.0),
                                ),
                                RawMaterialButton(
                                  onPressed: () => _loginSMS(context),
                                  child: Icon(
                                    FontAwesomeIcons.sms,
                                    color: Colors.lightBlue,
                                    size: 24.0,
                                  ),
                                  shape: CircleBorder(),
                                  elevation: 0.4,
                                  fillColor: Colors.grey.shade50,
                                  padding: const EdgeInsets.all(15.0),
                                ),
                                RawMaterialButton(
                                  onPressed: () => _loginGoogle(context),
                                  child: Icon(
                                    FontAwesomeIcons.google,
                                    color: Colors.red,
                                    size: 24.0,
                                  ),
                                  shape: CircleBorder(),
                                  elevation: 0.4,
                                  fillColor: Colors.grey.shade50,
                                  padding: const EdgeInsets.all(15.0),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 30.0,
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(S.of(context).dontHaveAccount),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                RegistrationScreen(),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(" " + S.of(context).signup,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )

//            FlatButton(
//              child: const Text('CANCEL'),
//              shape: const BeveledRectangleBorder(
//                borderRadius: BorderRadius.all(Radius.circular(7.0)),
//              ),
//              onPressed: () {
//                _usernameController.clear();
//                _passwordController.clear();
//                Navigator.pop(context);
//              },
//            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
//            if (widget.fromCart)
//              Positioned(
//                  left: 10,
//                  child: IconButton(
//                      icon: Icon(
//                        Icons.close,
//                        color: Colors.black,
//                      ),
//                      onPressed: () {
//                        Navigator.of(context).pop();
//                      })),
          ]),
        ),
      ),
    );
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: new Container(
            padding: new EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ));
        });
  }

  void hideLoading() {
    Navigator.of(context).pop();
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
