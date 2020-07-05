import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../common/config.dart' as config;
import '../../screens/deeplink_item.dart';

class MyOneSignal {
  void oneSignalInit(context){
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print(result.notification.jsonRepresentation().replaceAll("\\n", "\n"));
          int postId = result.notification.payload.additionalData['id'];
         if (postId != null){
           print('ItemDeepLink triggered');

           Navigator.push(
               context,
               MaterialPageRoute(
                   builder: (context) => ItemDeepLink(
                    itemId: postId,
                   ),),);
           return;
         }

    });
    OneSignal.shared.init(
        config.kOneSignalKey['appID'],
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: true
        }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  }
}