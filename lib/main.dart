import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:carmer_concours/screens/adout.dart';
import 'package:carmer_concours/screens/pdf_viewer.dart';
import 'package:carmer_concours/screens/concours.dart';
import 'package:carmer_concours/screens/results.dart';
import 'package:carmer_concours/screens/settings.dart';
import 'package:carmer_concours/utils/app_data.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();
  FirebaseAnalytics.instance.logAppOpen();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  AppData.init(savedThemeMode == AdaptiveThemeMode.dark);
  Intl.defaultLocale = Platform.localeName;
  AppData.sendNewUserAnalytics();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({Key? key, required this.savedThemeMode}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          title: 'Camer Concours',
          theme: theme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: 'concours',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
            Locale('fr', ''),
          ],
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
          routes: {
            "concours": (context) => ConcourScreen(
                  analytics: analytics,
                  observer: observer,
                ),
            "results": (context) => ResultScreen(
                  analytics: analytics,
                  observer: observer,
                ),
            "settings": (context) => const SettingsScreen(),
            "about": (context) => const AboutScreen(),
            "concour-full": (context) {
              final data = ModalRoute.of(context)?.settings.arguments
                  as Map<String, String>;
              return PDFScreen(
                title: data['title'] ?? '',
                pdf: data['pdf'] ?? '',
              );
            },
          },
        ),
      ),
    );
  }
}
