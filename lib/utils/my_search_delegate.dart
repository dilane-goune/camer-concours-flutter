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

          return ListView.builder(
            itemBuilder: (context, index) {
              return Txt(
                targets[index]['title'],
                style: TxtStyle()
                  ..fontSize(16)
                  ..margin(vertical: 5),
              );
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
