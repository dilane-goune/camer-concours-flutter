// ignore_for_file: invalid_return_type_for_catch_error

import 'package:carmer_concours/components/item_list_view.dart';
import 'package:carmer_concours/components/my_drawer.dart';
import 'package:carmer_concours/utils/my_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:division/division.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  const ResultScreen(
      {Key? key, required this.analytics, required this.observer})
      : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final results = <DocumentSnapshot>[];
  final db = FirebaseFirestore.instance;
  static const _maxLimit = 100;
  var _noConnection = false;
  var _isGettingMore = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> getData(bool isRefresh) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _noConnection = true;
      results.clear();
    } else {
      _noConnection = false;
    }

    final QuerySnapshot<Map<String, dynamic>> querySnapShoot;
    if (isRefresh) results.clear();
    if (results.isEmpty) {
      querySnapShoot = await db
          .collection('Results')
          .orderBy('publisedDate', descending: true)
          .limit(_maxLimit)
          .get();
    } else {
      querySnapShoot = await db
          .collection('Results')
          .orderBy('publisedDate', descending: true)
          .startAfterDocument(results[results.length - 1])
          .limit(_maxLimit)
          .get();
    }

    if (isRefresh) {
      results.addAll(querySnapShoot.docs);
    } else {
      results.addAll(querySnapShoot.docs);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData(false);
  }

  @override
  Widget build(BuildContext context) {
    final data = results.map((c) => c.data() as Map<String, dynamic>).toList();
    return Scaffold(
      appBar: AppBar(
        title: Txt(AppLocalizations.of(context)!.results),
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate(collectionName: 'Results'));
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Parent(
        style: ParentStyle(),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: _noConnection
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.noIternetConnection),
                      ElevatedButton(
                          onPressed: () => getData(false),
                          child: const Text('Refresh'))
                    ],
                  ),
                )
              : listView(data, 'Results', controller: _scrollController,
                  getMore: () {
                  setState(() {
                    _isGettingMore = true;
                  });
                  getData(false).then((value) => setState(() {
                        _isGettingMore = false;
                      }));
                }, isGettingMore: _isGettingMore),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 30.0,
        width: 30.0,
        child: FloatingActionButton(
          onPressed: _scrollDown,
          tooltip: AppLocalizations.of(context)!.scrollToTop,
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }

  Future<void> onRefresh() async {
    getData(true);
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}
