// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppData extends ChangeNotifier {
  static bool darkMode = false;

  AppData();

  static toggleDarkMode() {
    darkMode = !darkMode;
  }

  static void init(bool isDefaultDark) {
    darkMode = isDefaultDark;
  }

  static bool getDarkMode() {
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

Future<bool> checkForUpdate() async {
  //Get Current installed version of app
  final PackageInfo info = await PackageInfo.fromPlatform();
  double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

  try {
    var dio = Dio(BaseOptions(baseUrl: HOST_API));
    var res = await dio.get('/new-version');
    var data = res.data['newVersion'] as String;

    double newVersion = double.parse(data.trim().replaceAll(".", ""));

    return newVersion > currentVersion;
  } catch (exception) {
    return false;
  }
}

Future<void> showUpdateDialog(context) async {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = "New Update Available";
      String message =
          "There is a newer version of app available please update it now.";
      String btnLabel = "Update Now";
      String btnLabelCancel = "Later";
      return Platform.isIOS
          ? CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(btnLabel),
                  onPressed: () => _launchURL(APP_STORE_URL),
                ),
                ElevatedButton(
                  child: Text(btnLabelCancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          : AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(btnLabel),
                  onPressed: () => _launchURL(PLAY_STORE_URL),
                ),
                ElevatedButton(
                  child: Text(btnLabelCancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
    },
  );
}

_launchURL(String stringURL) async {
  var url = Uri.parse(stringURL);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

const HOST_API = 'https://192.168.43.34:8888/api';

const String APP_STORE_URL =
    'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=YOUR-APP-ID&mt=8';
const String PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=YOUR-APP-ID';

const DEFAULT_IMAGE =
    "https://firebasestorage.googleapis.com/v0/b/camer-concours.appspot.com/o/images%2Fdefault.jpg?alt=media&token=4d4a1ae5-6484-472f-b770-c8bad7330428";
