import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9348831435343142/4435005548';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9348831435343142/5225343034';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
      throw UnsupportedError("Unsupported platform");
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/2247696110';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/3986624511';
      }
      throw UnsupportedError("Unsupported platform");
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9348831435343142/7337937848';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9348831435343142/6160587548';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
