import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:carmer_concours/firebase_options.dart';
import 'package:carmer_concours/screens/adout.dart';
import 'package:carmer_concours/screens/pdf_viewer.dart';
import 'package:carmer_concours/screens/concours.dart';
import 'package:carmer_concours/screens/results.dart';
import 'package:carmer_concours/utils/app_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// Declared as global, outside of any class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void _firebaseMessagingForgroundHandler(RemoteMessage message) {
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.subscribeToTopic("all");
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForgroundHandler);

  await MobileAds.instance.initialize();

  FirebaseAnalytics.instance.logAppOpen();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  AppData.init(savedThemeMode == AdaptiveThemeMode.dark);
  AppData.sendNewUserAnalytics();
  AppData.checkUpdate();

  AwesomeNotifications().initialize(
    // null,
    'resource://drawable/launcher_icon',
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'notification_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
          channelGroupkey: 'notification_channel_group',
          channelGroupName: 'Notification Group')
    ],
  );

  runApp(MyApp(savedThemeMode: savedThemeMode));

  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({Key? key, required this.savedThemeMode}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().actionStream.asBroadcastStream().listen((action) {
      final payload = action.payload;
      Future(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFScreen(
              title: payload!['title'] ?? '',
              pdf: payload['pdf'] ?? '',
            ),
          ),
        );
      });
    });
    super.initState();
  }

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
        initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          title: 'Camer Concours',
          theme: theme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
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
          initialRoute: 'concours',
          routes: {
            "concours": (context) => ConcoursScreen(
                  analytics: MyApp.analytics,
                  observer: MyApp.observer,
                ),
            "results": (context) => ResultsScreen(
                  analytics: MyApp.analytics,
                  observer: MyApp.observer,
                ),
            "about": (context) => const AboutScreen(),
            "pdf-viewer": (context) {
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
