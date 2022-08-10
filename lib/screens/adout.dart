import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';

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

                    const Center(
                      child: CircleAvatar(
                        radius: 60,
                        foregroundImage: AssetImage('assets/images/logo.jpeg'),
                        child: Icon(
                          Icons.book,
                          size: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Txt(
                      'Camer Concours',
                      style: TxtStyle()
                        ..fontSize(18)
                        ..textAlign.center()
                        // ..margin(bottom: 5)
                        ..fontWeight(FontWeight.bold),
                    ),
                    // Txt(packageName),

                    Txt(
                      'Version $version',
                      style: TxtStyle()..textAlign.center(),
                    ),
                    const SizedBox(height: 40),

                    Txt(
                      'Developed by',
                      style: TxtStyle()
                        ..textAlign.center()
                        ..margin(bottom: 5),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Txt(
                          'Dilane Goune',
                          style: TxtStyle()
                            ..fontSize(16)
                            ..bold(),
                        ),
                        // Txt(
                        //   'website',
                        //   style: TxtStyle()
                        //     ..italic()
                        //     ..textColor(Colors.blue),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Txt(
                          'Ngniguepa Faha',
                          style: TxtStyle()
                            ..fontSize(16)
                            ..bold(),
                        ),
                      ],
                    ),

                    // Txt(version),
                    // Txt(buildNumber),
                    const SizedBox(height: 20),
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
                          onPressed: () {},
                          child: const Text('Rate this App'),
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
