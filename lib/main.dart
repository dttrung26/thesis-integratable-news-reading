import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logs/logs.dart';
import 'package:provider/provider.dart';

import 'app.dart';

final Log httpLog = new Log('http');

void main() async {
  httpLog.enabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  Provider.debugCheckInvalidValueType = null;

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(App());
}
