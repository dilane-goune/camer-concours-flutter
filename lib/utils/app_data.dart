// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppData extends ChangeNotifier {
  static bool darkMode = false;
  static Color textColor = Colors.white;
  static bool updateIsAvailable = false;
  static late String updateURL;
  static const String currentVersion = '1.0.1+2';

  static toggleDarkMode() {
    darkMode = !darkMode;
    textColor = darkMode ? Colors.white : Colors.black;
  }

  static void init(bool isDefaultDark) {
    darkMode = isDefaultDark;
    textColor = darkMode ? Colors.white : Colors.black;
  }

  static Future<void> requestNotificationPermission(
      BuildContext context) async {
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final bool? shouldRequestPermission = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(AppLocalizations.of(context)!.notifications),
              content: Text(
                AppLocalizations.of(context)!.notificationsPermissionMessage,
              ),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop<bool>(false);
                    },
                    child: Text(AppLocalizations.of(context)!.refuse)),
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop<bool>(true);
                    },
                    child: Text(AppLocalizations.of(context)!.grant)),
              ],
            );
          });

      if (shouldRequestPermission != null && shouldRequestPermission) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    }
  }

  static Future<void> sendNewUserAnalytics() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      var isOldUser = sharedPreferences.getBool('isOldUser');
      if (isOldUser == null || !isOldUser) {
        FirebaseAnalytics.instance.logEvent(
          name: 'new-user',
          parameters: {
            'date': DateTime.now().toIso8601String(),
          },
        ).then((value) {
          sharedPreferences.setBool('isOldUser', true);
        });
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  static Future<void> checkUpdate() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('AppVersions')
          .where('platform', isEqualTo: Platform.isAndroid ? 'Android' : 'IOS')
          .orderBy('version', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs[0].data();
        if ((data['version'] as String).compareTo(currentVersion) > 0) {
          updateIsAvailable = true;
          updateURL = data['url'] as String;
        }
      }
    } catch (_) {}
  }
}

const DEFAULT_IMAGE =
    "https://firebasestorage.googleapis.com/v0/b/camer-concours.appspot.com/o/images%2Fdefault.jpg?alt=media&token=4d4a1ae5-6484-472f-b770-c8bad7330428";
