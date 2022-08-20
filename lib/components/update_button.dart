import 'dart:async';

import 'package:carmer_concours/utils/app_data.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';

class UpdateButton extends StatefulWidget {
  final void Function(int n)? onPressed;
  const UpdateButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  State<UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  bool _scaleUp = false;

  void _animate() {
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() => _scaleUp = !_scaleUp);
    });
  }

  @override
  void initState() {
    super.initState();
    // _animate();
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..background.color(Colors.green)
        ..animate(200, Curves.easeInOut)
        ..padding(horizontal: 10)
        ..borderRadius(all: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/update-icon.png', height: 40, width: 40),
          Txt(
            'An update is available',
            // AppLocalizations.of(context)!.updateIsAvailable
            style: TxtStyle()
              ..fontFamily('Roboto')
              ..fontSize(16)
              ..textColor(AppData.textColor),
          ),
          Parent(
            style: ParentStyle()
              ..scale(_scaleUp ? 1.1 : 1)
              ..animate(200, Curves.easeInOut),
            child: ElevatedButton(
              onPressed: () {},
              child: const Txt('GET IT'
                  // AppLocalizations.of(context)!.getIt
                  ),
            ),
          )
        ],
      ),
    );
  }
}
