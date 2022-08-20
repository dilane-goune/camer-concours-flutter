import 'dart:io';

import 'package:carmer_concours/components/my_drawer.dart';
import 'package:carmer_concours/components/result_item.dart';
import 'package:carmer_concours/functions/get_data.dart';
import 'package:carmer_concours/utils/my_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:division/division.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultsScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  const ResultsScreen(
      {Key? key, required this.analytics, required this.observer})
      : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _results = <DocumentSnapshot>[];
  final ScrollController _scrollController = ScrollController();
  static const collection = 'Results';

  bool _isRefreshing = true;
  bool _isGettingMore = false;
  bool _failedToFecth = false;

  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _getData().then((value) => setState(() => _isRefreshing = false));
  }

  Future<void> _getData({bool isRefresh = false}) async {
    try {
      _failedToFecth = false;
      if (isRefresh) {
        _results.clear();
        _lastDoc = null;
      }

      var data = await fetchData(collection: collection, lastDoc: _lastDoc);
      _results.addAll(data);
      if (_results.isNotEmpty) {
        _lastDoc = _results[_results.length - 1];
      } else {
        _lastDoc = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      setState(() => _failedToFecth = true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  delegate: CustomSearchDelegate(collectionName: collection));
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _isRefreshing
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.pleaseWait),
                  const SizedBox(width: 5),
                  Platform.isAndroid
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                            strokeWidth: 2,
                          ),
                        )
                      : const CupertinoActivityIndicator()
                ],
              ),
            )
          : _failedToFecth
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.noIternetConnection),
                      ElevatedButton(
                          onPressed: () => _getData(isRefresh: true)
                              .then((value) => setState(() {})),
                          child: Text(AppLocalizations.of(context)!.refresh))
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _getData(isRefresh: true).then((value) => setState(() {}));
                  },
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      ..._results
                          .map((doc) => ResultItem.fromObject(
                              doc.data() as Map<String, dynamic>))
                          .toList(),
                      Center(
                        child: TextButton(
                          onPressed: _isGettingMore
                              ? null
                              : () {
                                  setState(() => _isGettingMore = true);
                                  _getData().then((value) =>
                                      setState(() => _isGettingMore = false));
                                },
                          child: _isGettingMore
                              ? Platform.isAndroid
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const CupertinoActivityIndicator()
                              : Text(AppLocalizations.of(context)!.more),
                        ),
                      )
                    ],
                  ),
                ),
      floatingActionButton: _failedToFecth
          ? null
          : SizedBox(
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

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}
