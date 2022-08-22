import 'dart:io';

import 'package:carmer_concours/utils/app_data.dart'
    show AppData, DEFAULT_IMAGE;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ResultItem extends StatefulWidget {
  // final String id;
  final String title;
  final int? numberSat;
  final int? numberPassed;
  final DateTime publishedDate;
  final DateTime createdAt;
  final Map<String, dynamic> pdf;
  final DocumentReference schoolRef;

  ResultItem.fromObject(Map<String, dynamic> item, {Key? key})
      : title = item['title'] as String,
        //  id = item['id'] as String,
        numberSat = item['numberSat'] as int?,
        numberPassed = item['numberPassed'] as int?,
        publishedDate = DateTime.parse(item['publishedDate'] as String),
        createdAt = DateTime.parse(item['createdAt'] as String),
        pdf = item['pdf'] as Map<String, dynamic>,
        schoolRef = item['schoolRef'] as DocumentReference,
        super(key: key);

  @override
  State<ResultItem> createState() => _ResultItemState();
}

class _ResultItemState extends State<ResultItem> {
  Map<String, dynamic> school = {
    'logo': {'url': DEFAULT_IMAGE},
    'name': '',
    'acronym': '',
  };
  Future<void> getSchool() async {
    final snapshot = await widget.schoolRef.get();
    if (snapshot.exists) {
      setState(() {
        school = snapshot.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSchool();
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..borderRadius(all: 10)
        ..border(all: .5, color: Colors.grey)
        ..padding(all: 5, bottom: 0)
        ..margin(all: 5),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                foregroundImage: NetworkImage('${school['logo']['url']}'),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      widget.title,
                      style: TxtStyle()
                        ..fontSize(18)
                        ..textColor(AppData.textColor),
                    ),
                    Txt(
                      '${school['name']}',
                      style: TxtStyle()
                        ..fontSize(14)
                        ..textColor(AppData.textColor)
                        ..textColor(AppData.textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          if (widget.numberSat != null)
            Label(
                label: AppLocalizations.of(context)!.numberOfCandidates,
                value:
                    '${widget.numberSat} ${AppLocalizations.of(context)!.candites}'),
          if (widget.numberPassed != null)
            Label(
                label: AppLocalizations.of(context)!.numberPassed,
                value:
                    '${widget.numberPassed} ${AppLocalizations.of(context)!.candites}'),
          // const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Txt(
                // ignore: prefer_interpolation_to_compose_strings
                AppLocalizations.of(context)!.publishedDate +
                    ' ' +
                    DateFormat.yMMMMd(Platform.localeName)
                        .format(widget.publishedDate),
                style: TxtStyle()
                  ..italic()
                  ..textColor(Colors.red.shade400),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'pdf-viewer',
                      arguments: <String, String>{
                        'title': widget.title,
                        'pdf': widget.pdf['url'] ?? ''
                      });
                },
                child: Text(AppLocalizations.of(context)!.list.toUpperCase()),
              )
            ],
          )
        ],
      ),
    );
  }
}

class Label extends StatelessWidget {
  final String label;
  final String value;
  final TxtStyle? valueStyle;
  const Label(
      {Key? key, required this.label, required this.value, this.valueStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Txt(label,
              style: TxtStyle()
                ..margin(bottom: 3, right: 10)
                ..textColor(AppData.textColor)),
          Txt(
            value,
            style: TxtStyle()
              ..add(valueStyle)
              ..textOverflow(TextOverflow.ellipsis)
              ..textColor(AppData.textColor),
          )
        ],
      ),
    );
  }
}
