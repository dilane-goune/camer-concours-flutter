// ignore_for_file: constant_identifier_names

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  static bool darkMode = false;

  AppData();

  static toggleDarkMode() {
    darkMode = !darkMode;
  }

  static void init(bool isDefaultDark) {
    darkMode = isDefaultDark;
  }

  static bool get getDarkMode {
    return darkMode;
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
}

const DEFAULT_IMAGE =
    "https://firebasestorage.googleapis.com/v0/b/camer-concours.appspot.com/o/images%2Fdefault.jpg?alt=media&token=4d4a1ae5-6484-472f-b770-c8bad7330428";
