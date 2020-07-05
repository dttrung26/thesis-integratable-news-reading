import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:provider/provider.dart';

import '../models/app.dart';
import '../common/config.dart' as config;
import '../common/styles.dart';
import 'login.dart';
import 'registration.dart';

class OnBoardScreen extends StatefulWidget {
  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  List<Slide> slides = [];
  final isRequiredLogin = config.kAdvanceConfig['IsRequiredLogin'];

  @override
  void initState() {
    super.initState();

    Widget loginWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image.asset(
          "assets/images/fogg-order-completed.png",
          height: 200,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  "Sign In",
                  style: TextStyle(color: kTeal400, fontSize: 20.0),
                ),
                onTap: () {
                  Provider.of<AppModel>(context, listen: false).isAccessedByOnBoardingBoard =
                      true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen(),
                    ),
                  );

//                  var user = Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (BuildContext context) => LoginScreen()));
//                  if (user != null) {
//                    Navigator.pushReplacementNamed(context, '/home');
//                  }
                },
              ),
              Text(
                "    |    ",
                style: TextStyle(color: kTeal400, fontSize: 20.0),
              ),
              GestureDetector(
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: kTeal400, fontSize: 20.0),
                ),
                onTap: () {
                  Provider.of<AppModel>(context).isAccessedByOnBoardingBoard =
                      true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => RegistrationScreen(),
                    ),
                  );
//                  var user = Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (BuildContext context) =>
//                              RegistrationScreen()));
//                  if (user != null) {
//                    Navigator.pushReplacementNamed(context, '/home');
//                  }
                },
              ),
            ],
          ),
        ),
      ],
    );

    for (int i = 0; i < config.onBoardingData.length; i++) {
      Slide slide = Slide(
        title: config.onBoardingData[i]['title'],
        description: config.onBoardingData[i]['desc'],
        marginTitle: EdgeInsets.only(
          top: 125.0,
          bottom: 50.0,
        ),
        maxLineTextDescription: 2,
        styleTitle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: kGrey900,
        ),
        backgroundColor: Colors.white,
        marginDescription: EdgeInsets.fromLTRB(20.0, 75.0, 20.0, 0),
        styleDescription: TextStyle(
          fontSize: 15.0,
          color: kGrey600,
        ),
        foregroundImageFit: BoxFit.fitWidth,
      );

      if (i == 2) {
        slide.centerWidget = loginWidget;
      } else {
        slide.pathImage = config.onBoardingData[i]['image'];
      }

      slides.add(slide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      styleNameSkipBtn: TextStyle(color: kGrey900),
      styleNameDoneBtn: TextStyle(color: kGrey900),
      nameNextBtn: "NEXT >",
      nameDoneBtn: isRequiredLogin ? '' : "DONE",
      onDonePress: () async {
        Navigator.pushNamed(context, '/home');
      },
    );
  }
}
