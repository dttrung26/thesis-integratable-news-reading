import '../../common/config.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalWapper {
  init() {
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print(result.notification.jsonRepresentation().replaceAll("\\n", "\n"));
    });
    OneSignal.shared.init(kOneSignalKey['appID'], iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: true
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
  }
}
