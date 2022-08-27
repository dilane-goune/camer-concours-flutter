import 'package:carmer_concours/utils/ad_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFScreen extends StatefulWidget {
  final String title;
  final String pdf;

  const PDFScreen({Key? key, required this.title, required this.pdf})
      : super(key: key);
  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _showSearchBar = false;
  bool _isFinding = false;
  final _findController = TextEditingController();
  PdfTextSearchResult _pdfTextSearchResult = PdfTextSearchResult();
  FocusNode? _focusNode;
  InterstitialAd? _interstitialAd;
  bool _errorLoadingPDF = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    super.initState();
    FirebaseAnalytics.instance
        .logEvent(name: "opened_a_pdf", parameters: {"title": widget.title});
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _pdfTextSearchResult.clear();
    _findController.dispose();
    _pdfViewerController.clearSelection();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_interstitialAd != null && !_errorLoadingPDF) {
          _interstitialAd?.show();
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: _showSearchBar
              ? TextField(
                  decoration: const InputDecoration(hintText: 'Find...'),
                  controller: _findController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _handleOnSubmitFind,
                )
              : Text(widget.title, style: const TextStyle(fontSize: 12)),
          leading: const BackButton(),
          leadingWidth: 30,
          toolbarHeight: 50,
          elevation: 2,
          actions: [
            if (_isFinding)
              const CupertinoActivityIndicator()
            else
              SizedBox(
                width: 30,
                child: IconButton(
                  icon: Icon(
                    _showSearchBar ? Icons.clear : Icons.search,
                    size: 20,
                  ),
                  onPressed: () {
                    _showSearchBar = !_showSearchBar;
                    if (_showSearchBar) _focusNode?.requestFocus();
                    _pdfTextSearchResult.clear();
                    _findController.clear();
                    setState(() {});
                  },
                ),
              ),
            SizedBox(
              width: 30,
              child: IconButton(
                icon: Icon(_showSearchBar
                    ? Icons.navigate_before
                    : Icons.keyboard_arrow_up),
                onPressed: () {
                  if (_showSearchBar) {
                    _pdfTextSearchResult.previousInstance();
                    setState(() {});
                  } else {
                    _pdfViewerController.previousPage();
                  }
                },
              ),
            ),
            SizedBox(
              width: 30,
              child: IconButton(
                icon: Icon(
                  _showSearchBar
                      ? Icons.navigate_next
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  if (_showSearchBar) {
                    _pdfTextSearchResult.nextInstance();
                    setState(() {});
                  } else {
                    _pdfViewerController.nextPage();
                  }
                },
              ),
            ),
            Visibility(
              visible: _pdfTextSearchResult.hasResult,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: Center(
                    child: Text(
                        '${_pdfTextSearchResult.currentInstanceIndex}/${_pdfTextSearchResult.totalInstanceCount}')),
              ),
            ),
            if (!_showSearchBar)
              SizedBox(
                width: 40,
                child: IconButton(
                    onPressed: () {
                      launchUrl(Uri.parse(widget.pdf),
                          mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(
                      Icons.download,
                      size: 20,
                    )),
              )
          ],
          automaticallyImplyLeading: false,
        ),
        body: SfPdfViewer.network(
          widget.pdf,
          controller: _pdfViewerController,
          canShowScrollHead: !_showSearchBar,
          onDocumentLoadFailed: handleFailedToLoadPdf,
          enableTextSelection: false,
          currentSearchTextHighlightColor:
              const Color.fromARGB(221, 37, 163, 26),
          otherSearchTextHighlightColor: const Color.fromARGB(172, 196, 41, 41),
        ),
      ),
    );
  }

  void handleFailedToLoadPdf(PdfDocumentLoadFailedDetails e) {
    _errorLoadingPDF = true;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('PDF Error'),
            content: const Text('An error occured while loading the pdf file.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'))
            ],
          );
        });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.of(context).pop();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('failed to load ad');
            print(err);
          }
        },
      ),
    );
  }

  void _handleOnSubmitFind(String value) async {
    _pdfTextSearchResult.clear();
    setState(() => _isFinding = true);
    await Future.delayed(Duration.zero);
    if (_findController.value.text.trim().isNotEmpty) {
      _pdfTextSearchResult = await _pdfViewerController
          .searchText(_findController.value.text.trim());
    }
    setState(() => _isFinding = false);
  }
}
