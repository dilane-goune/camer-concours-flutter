import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:carmer_concours/components/concour_item.dart';
import 'package:carmer_concours/components/my_drawer.dart';
import 'package:carmer_concours/functions/get_data.dart';
import 'package:carmer_concours/screens/pdf_viewer.dart';
import 'package:carmer_concours/utils/app_data.dart';
import 'package:carmer_concours/utils/my_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:division/division.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConcoursScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  const ConcoursScreen(
      {Key? key, required this.analytics, required this.observer})
      : super(key: key);

  @override
  State<ConcoursScreen> createState() => _ConcoursScreenState();
}

class _ConcoursScreenState extends State<ConcoursScreen> {
  final _concours = <DocumentSnapshot>[];
  final ScrollController _scrollController = ScrollController();
  static const collection = 'Concours';

  bool _isRefreshing = true;
  bool _isGettingMore = false;
  bool _failedToFecth = false;

  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    AppData.requestNotificationPermission(context);
    AwesomeNotifications().actionStream.listen((action) {
      final payload = action.payload;
      Future(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFScreen(
              title: payload!['title'] ?? '',
              pdf: payload['pdf'] ?? '',
            ),
          ),
        );
      });
    });

    _getData().then((value) => setState(() => _isRefreshing = false));
  }

  @override
  void dispose() {
    AwesomeNotifications().dispose();
    super.dispose();
  }

  Future<void> _getData({bool isRefresh = false}) async {
    try {
      _failedToFecth = false;
      if (isRefresh) {
        _concours.clear();
        _lastDoc = null;
      }

      var data = await fetchData(collection: collection, lastDoc: _lastDoc);
      _concours.addAll(data);
      if (_concours.isNotEmpty) {
        _lastDoc = _concours[_concours.length - 1];
      } else {
        _lastDoc = null;
      }
    } catch (e) {
      setState(() => _failedToFecth = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(AppLocalizations.of(context)!.concours),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(collectionName: collection),
              );
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
                          onPressed: () {
                            setState(() => _isRefreshing = true);
                            _getData(isRefresh: true).then((value) =>
                                setState(() => _isRefreshing = false));
                          },
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
                      ..._concours
                          .map((doc) => ConcourItem.fromObject(
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
