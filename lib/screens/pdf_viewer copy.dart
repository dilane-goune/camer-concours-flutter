import 'dart:io';

import 'package:carmer_concours/utils/ad_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PDFScreen extends StatefulWidget {
  final String title;
  final String pdf;

  const PDFScreen({Key? key, required this.title, required this.pdf})
      : super(key: key);

  @override
  State<PDFScreen> createState() => _ConcourFullScreenState();
}

class _ConcourFullScreenState extends State<PDFScreen> {
  late PdfViewerController _pdfViewerController;
  late PdfTextSearchResult _searchResult;
  late OverlayEntry? _overlayEntry;

  InterstitialAd? _interstitialAd;
  var errorLoadingPDF = false;
  var _showSearchInput = false;
  final _searchInputController = TextEditingController();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
    _loadInterstitialAd();
    super.initState();
    FirebaseAnalytics.instance
        .logEvent(name: "opened_a_pdf", parameters: {"title": widget.title});
  }

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState? _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion?.center.dy ?? 0 - 55,
        left: details.globalSelectedRegion?.bottomLeft.dx,
        child: ElevatedButton(
            child: Text('Copy', style: TextStyle(fontSize: 17)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details.selectedText));
              _pdfViewerController.clearSelection();
            }),
      ),
    );
    _overlayState?.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_interstitialAd != null && !errorLoadingPDF) {
          _interstitialAd?.show();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 16)),
          toolbarHeight: 50,
          leading: IconButton(
              onPressed: () {
                if (_interstitialAd != null && !errorLoadingPDF) {
                  _interstitialAd?.show();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
              )),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search,
              ),
              onPressed: () async {
                _searchResult = await _pdfViewerController.searchText('Build',
                    searchOption: TextSearchOption.caseSensitive);
                print(
                    'Total instance count: ${_searchResult.totalInstanceCount}');
              },
            ),
            Visibility(
              visible: _searchResult.hasResult,
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_up,
                ),
                onPressed: () {
                  _searchResult.previousInstance();
                },
              ),
            ),
            Visibility(
              visible: _searchResult.hasResult,
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  _searchResult.nextInstance();
                },
              ),
            ),

            Visibility(
              visible: _searchResult.hasResult,
              child: IconButton(
                icon: Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  setState(() {
                    _searchResult.clear();
                  });
                },
              ),
            ),

            // IconButton(
            //   icon: const Icon(
            //     Icons.keyboard_arrow_up,
            //   ),
            //   onPressed: () {
            //     _pdfViewerController.previousPage();
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.keyboard_arrow_down,
            //   ),
            //   onPressed: () {
            //     _pdfViewerController.nextPage();
            //   },
            // )
          ],
        ),
        body: SfPdfViewer.network(
          'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
          controller: _pdfViewerController,
          onDocumentLoadFailed: (e) {
            errorLoadingPDF = true;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('PDF Error'),
                    content: const Text(
                        'An error occured while loading the pdf file.'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'))
                    ],
                  );
                });
          },
          onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
            if (details.selectedText == null && _overlayEntry != null) {
              _overlayEntry?.remove();
              _overlayEntry = null;
            } else if (details.selectedText != null && _overlayEntry == null) {
              _showContextMenu(context, details);
            }
          },
        ),
      ),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.pop(context);
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {},
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
