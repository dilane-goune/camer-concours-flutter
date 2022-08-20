import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:carmer_concours/components/update_button.dart';
import 'package:carmer_concours/utils/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 70,
                  foregroundImage: AssetImage('assets/images/logo.png'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: Text(AppLocalizations.of(context)!.concours),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'concours');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: Text(AppLocalizations.of(context)!.results),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, 'results');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'about');
            },
          ),
          ListTile(
            leading: Icon(
              AppData.darkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: Text(AppLocalizations.of(context)!.darkMode),
            trailing: Switch(
              value: AppData.darkMode,
              onChanged: toggleDarkMode,
            ),
          ),
          const UpdateButton(),
        ],
      ),
    );
  }

  void toggleDarkMode(bool newValue) {
    if (newValue) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    setState(() {
      AppData.toggleDarkMode();
    });
    // Navigator.pop(context);
  }
}
