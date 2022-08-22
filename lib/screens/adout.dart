import 'package:carmer_concours/utils/app_data.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.about)),
        body: FutureBuilder(
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.done) {
              PackageInfo packageInfo = asyncSnapshot.data as PackageInfo;
              String version = packageInfo.version;
              return Parent(
                style: ParentStyle()..padding(horizontal: 10),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 110,
                        width: 110,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Txt(
                    //   'Camer Concours',
                    //   style: TxtStyle()
                    //     ..fontSize(18)
                    //     ..textAlign.center()
                    //     ..textColor(AppData.textColor)
                    //     // ..margin(bottom: 5)
                    //     ..fontWeight(FontWeight.bold),
                    // ),
                    Txt(
                      'Version $version',
                      style: TxtStyle()
                        ..textAlign.center()
                        ..textColor(AppData.textColor),
                    ),
                    const SizedBox(height: 20),
                    Txt(
                      AppLocalizations.of(context)!.develppedBy,
                      style: TxtStyle()
                        ..textAlign.center()
                        ..margin(bottom: 5)
                        ..fontSize(12)
                        ..italic()
                        ..textColor(AppData.textColor)
                        ..opacity(.5),
                    ),
                    ListTile(
                      // leading: const Icon(Icons.person, size: 40),
                      title: const Text('Dilane Goune'),
                      subtitle: const Text('Sofware Developer'),
                      trailing: IconButton(
                        onPressed: () {
                          launchUrl(
                              Uri.parse('https://github.com/dilane-goune'),
                              mode: LaunchMode.externalApplication);
                        },
                        icon:
                            Image.asset('assets/images/github-transparent.png'),
                        tooltip: 'Github',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      // leading: const Icon(Icons.person, size: 40),
                      title: const Text('Ngniguepa Faha'),
                      subtitle: const Text('Sofware Developer'),
                      trailing: IconButton(
                        onPressed: () {
                          launchUrl(Uri.parse('https://github.com/johnneper'),
                              mode: LaunchMode.externalApplication);
                        },
                        icon:
                            Image.asset('assets/images/github-transparent.png'),
                        tooltip: 'Github',
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            showLicensePage(context: context);
                          },
                          child: const Text('Licences'),
                        ),
                        TextButton(
                          onPressed: null,
                          child:
                              Text(AppLocalizations.of(context)!.rateThisApp),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          future: PackageInfo.fromPlatform(),
        ));
  }
}
