// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  static bool darkMode = false;
  static Color textColor = Colors.white;
  static bool updateIsAvailable = false;
  static late String updateURL;
  static const String currentVersion = '1.0.0';

  static toggleDarkMode() {
    darkMode = !darkMode;
    textColor = darkMode ? Colors.white : Colors.black;
  }

  static void init(bool isDefaultDark) {
    darkMode = isDefaultDark;
    textColor = darkMode ? Colors.white : Colors.black;
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

  static Future<void> requestFCMPernission() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    var isAutthorised = sharedPreferences.getBool('authorizedFCM');
    if (isAutthorised != null && isAutthorised) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await sharedPreferences.setBool('authorizedFCM', true);
    }
  }

  static Future<void> checkUpdate() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('AppVersions')
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
    } on Exception catch (_) {}
  }
}

const DEFAULT_IMAGE =
    "https://firebasestorage.googleapis.com/v0/b/camer-concours.appspot.com/o/images%2Fdefault.jpg?alt=media&token=4d4a1ae5-6484-472f-b770-c8bad7330428";
