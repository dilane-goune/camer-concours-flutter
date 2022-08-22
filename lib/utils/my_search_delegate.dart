import 'package:carmer_concours/components/item_list_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomSearchDelegate extends SearchDelegate {
  final String collectionName;
  CustomSearchDelegate({required this.collectionName}) : super();

  final db = FirebaseFirestore.instance;
  final suggestions = <String>[];
// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          if (asyncSnapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.failedToLoadData),
            );
          }
          final targets = asyncSnapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemBuilder: (context, index) {
              return listView(targets, collectionName);
            },
            itemCount: targets.length,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: getSearchData(),
    );
  }

  // last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          if (asyncSnapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.failedToLoadData),
            );
          }
          final targets = asyncSnapshot.data as List<Map<String, dynamic>>;

          return Parent(
            style: ParentStyle()..padding(horizontal: 10),
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Parent(
                  style: ParentStyle()..ripple(true),
                  gesture: Gestures()
                    ..onTap(() {
                      close(context, null);
                      Navigator.pushNamed(context, 'pdf-viewer',
                          arguments: <String, String>{
                            'title': targets[index]['title'],
                            'pdf': targets[index]['pdf']['url'] ?? ''
                          });
                    }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt(
                        targets[index]['title'],
                        style: TxtStyle()
                          ..fontSize(12)
                          ..maxLines(3)
                          ..textOverflow(TextOverflow.ellipsis)
                          ..maxWidth(MediaQuery.of(context).size.width * .84),
                      ),
                      Txt(
                        targets[index]['publishedDate']
                            .toString()
                            .substring(0, 4),
                        style: TxtStyle()
                          ..fontSize(14)
                          ..margin(vertical: 5)
                          ..textColor(Colors.green),
                      ),
                    ],
                  ),
                );
              },
              itemCount: targets.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: getSearchData(),
    );
  }

  Future<List<Map<String, dynamic>>> getSearchData() async {
    if (query.isEmpty) return [];
    final querySnapShoot = await db
        .collection(collectionName)
        .orderBy("searchKey")
        .where('searchKey', isGreaterThanOrEqualTo: query)
        .where('searchKey', isLessThan: '$query\uf7ff')
        .get();

    return querySnapShoot.docs.map((d) => d.data()).toList();
  }
}
