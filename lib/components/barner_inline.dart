import 'package:carmer_concours/utils/ad_helper.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyBarnerAd extends StatefulWidget {
  const MyBarnerAd({Key? key}) : super(key: key);

  @override
  State<MyBarnerAd> createState() => _MyBarnerAdState();
}

class _MyBarnerAdState extends State<MyBarnerAd> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.fluid,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _ad = null;
          });
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _ad?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..borderRadius(all: 10)
        ..border(all: .5, color: Colors.grey)
        ..margin(horizontal: 5)
        ..width(MediaQuery.of(context).size.width)
        ..height(60),
      child: _ad != null ? AdWidget(ad: _ad!) : Container(),
    );
  }
}
