import 'dart:io';

import 'package:carmer_concours/utils/app_data.dart';
import 'package:carmer_concours/utils/get_level_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ConcourItem extends StatefulWidget {
  // final String id;
  final String title;
  final int numberOfPlaces;
  final num feel;
  final DateTime writingDate;
  final DateTime documentsDeadLine;
  final DateTime publisedDate;
  final DateTime createdAt;
  final String level;
  final Map<String, dynamic> pdf;
  final DocumentReference schoolRef;

  ConcourItem.fromObject(Map<String, dynamic> item, {Key? key})
      : feel = item['feel'] as num,
        title = item['title'] as String,
        numberOfPlaces = item['numberOfPlaces'] as int,
        writingDate = DateTime.parse(item['writingDate'] as String),
        documentsDeadLine = DateTime.parse(item['documentsDeadLine'] as String),
        publisedDate = DateTime.parse(item['publisedDate'] as String),
        createdAt = DateTime.parse(item['createdAt'] as String),
        level = item['level'] as String,
        pdf = item['pdf'] as Map<String, dynamic>,
        schoolRef = item['schoolRef'] as DocumentReference,
        super(key: key);

  @override
  State<ConcourItem> createState() => _ConcourItemState();
}

class _ConcourItemState extends State<ConcourItem> {
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
    var valueStyle = TxtStyle()
      ..maxWidth(MediaQuery.of(context).size.width * .6);
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
                      '${AppLocalizations.of(context)!.concour} ${school['acronym']} ${widget.publisedDate.year}',
                      style: TxtStyle()..fontSize(18),
                    ),
                    Txt(
                      '${school['name']}',
                      style: TxtStyle()..fontSize(14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Label(
              label: AppLocalizations.of(context)!.numberOfPlaces,
              value: '${widget.numberOfPlaces} places'),
          Label(
            label: AppLocalizations.of(context)!.writingDate,
            value: DateFormat.yMMMMd(Platform.localeName)
                .format(widget.writingDate),
          ),
          Label(
            label: AppLocalizations.of(context)!.documebtsDeadLine,
            value: DateFormat.yMMMMd(Platform.localeName)
                .format(widget.documentsDeadLine),
          ),
          Label(
            label: AppLocalizations.of(context)!.feel,
            value: '${widget.feel} FCFA',
          ),
          Label(
            label: AppLocalizations.of(context)!.requiredLevels,
            value: getLevelString(widget.level),
            valueStyle: valueStyle,
          ),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Txt(
                '${AppLocalizations.of(context)!.publisedDate} ${DateFormat.yMMMMd(Platform.localeName).format(widget.publisedDate)}',
                style: TxtStyle()
                  ..italic()
                  ..textColor(Colors.red),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'concour-full',
                      arguments: <String, String>{
                        'title': widget.title,
                        'pdf': widget.pdf['url'] ?? ''
                      });
                },
                child: Text(AppLocalizations.of(context)!.arrete.toUpperCase()),
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
          Txt(label, style: TxtStyle()..margin(bottom: 3, right: 10)),
          Txt(
            value,
            style: TxtStyle()
              ..add(valueStyle)
              ..textOverflow(TextOverflow.ellipsis),
          )
        ],
      ),
    );
  }
}
