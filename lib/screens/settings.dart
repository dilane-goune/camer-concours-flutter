import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:carmer_concours/utils/app_data.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void toggleDarkMode(bool newValue) {
    if (newValue) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    setState(() {
      AppData.toggleDarkMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Parent(
        style: ParentStyle()..padding(horizontal: 5),
        child: ListView(
          children: [
            Parent(
              style: ParentStyle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Txt(
                    AppLocalizations.of(context)!.darkMode,
                    style: TxtStyle()..fontSize(18),
                  ),
                  Switch(
                      value: AppData.getDarkMode(), onChanged: toggleDarkMode)
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
