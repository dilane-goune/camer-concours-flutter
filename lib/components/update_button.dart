import 'dart:async';

import 'package:carmer_concours/utils/app_data.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateButton extends StatefulWidget {
  final void Function()? onPressed;
  const UpdateButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  State<UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  bool _scaleUp = false;
  late Timer _timer;

  void _animate() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() => _scaleUp = !_scaleUp);
    });
  }

  @override
  void initState() {
    super.initState();
    _animate();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..background.color(Colors.green)
        ..padding(horizontal: 5, vertical: 5)
        ..margin(horizontal: 5)
        ..borderRadius(all: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/update-icon.png', height: 30, width: 30),
          Txt(
            // 'An update is available',
            AppLocalizations.of(context)!.updateIsAvailable,
            style: TxtStyle()
              ..fontFamily('Roboto')
              ..fontSize(11)
              ..textColor(AppData.textColor),
          ),
          Parent(
            style: ParentStyle()
              ..scale(_scaleUp ? 1.1 : 1)
              ..animate(500, Curves.easeInOut),
            child: SizedBox(
              // width: 110.0,
              height: 30.0,
              child: ElevatedButton(
                onPressed: widget.onPressed,
                child: Txt(
                  AppLocalizations.of(context)!.getIt,
                  style: TxtStyle()
                    ..fontSize(10)
                    ..textColor(Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
