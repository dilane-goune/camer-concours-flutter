import 'dart:io';

import 'package:carmer_concours/utils/ad_helper.dart';
import 'package:division/division.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Represents the PDFScreen for Navigation
class PDFScreen extends StatefulWidget {
  final String title;
  final String pdf;

  const PDFScreen({Key? key, required this.title, required this.pdf})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _PDFScreen createState() => _PDFScreen();
}

class _PDFScreen extends State<PDFScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
  bool _showSearchBar = false;
  bool _showScrollHead = true;
  // bool _shouldPopWithoutAd = false;

  // OverlayEntry? _overlayEntry;

  InterstitialAd? _interstitialAd;
  bool errorLoadingPDF = false;

  LocalHistoryEntry? _historyEntry;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    super.initState();
    FirebaseAnalytics.instance
        .logEvent(name: "opened_a_pdf", parameters: {"title": widget.title});
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  void _handleHistoryEntryRemoved() {
    _textSearchKey.currentState?.clearSearch();
    setState(() {
      _showSearchBar = false;
    });
    _historyEntry = null;
  }

  // void _showContextMenu(
  //     BuildContext context, PdfTextSelectionChangedDetails details) {
  //   final OverlayState overlayState = Overlay.of(context)!;
  //   _overlayEntry = OverlayEntry(
  //     builder: (context) => Positioned(
  //       top: details.globalSelectedRegion!.center.dy - 55,
  //       left: details.globalSelectedRegion!.bottomLeft.dx,
  //       child: TextButton(
  //         onPressed: () {
  //           Clipboard.setData(ClipboardData(text: details.selectedText));
  //           _pdfViewerController.clearSelection();
  //         },
  //         child: Txt(
  //           'Copy',
  //           style: TxtStyle()
  //             ..padding(horizontal: 10, vertical: 5)
  //             ..background.color(Colors.grey.shade400)
  //             ..borderRadius(all: 15),
  //         ),
  //       ),
  //     ),
  //     maintainState: false,
  //   );
  //   _shouldPopWithoutAd = true;
  //   overlayState.insert(_overlayEntry!);
  //   _shouldPopWithoutAd = false;
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (_shouldPopWithoutAd) return false;
        if (_interstitialAd != null && !errorLoadingPDF) {
          _interstitialAd?.show();
        }

        return true;
      },
      child: Scaffold(
        appBar: _showSearchBar
            ? AppBar(
                toolbarHeight: 50,
                flexibleSpace: SafeArea(
                  child: SearchToolbar(
                    key: _textSearchKey,
                    showTooltip: true,
                    controller: _pdfViewerController,
                    onTap: (Object toolbarItem) async {
                      if (toolbarItem.toString() == 'Cancel Search') {
                        setState(() {
                          _showSearchBar = false;
                          _showScrollHead = true;
                        });
                      }
                      if (toolbarItem.toString() == 'noResultFound') {
                        setState(() {
                          _textSearchKey.currentState?._showToast = true;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() {
                          _textSearchKey.currentState?._showToast = false;
                        });
                      }
                    },
                  ),
                ),
                automaticallyImplyLeading: false,
              )
            : AppBar(
                title: Text(widget.title, style: const TextStyle(fontSize: 16)),
                leading: const BackButton(),
                toolbarHeight: 50,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _showScrollHead = false;
                        _showSearchBar = true;
                        _ensureHistoryEntry();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () {
                      _pdfViewerController.previousPage();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () {
                      _pdfViewerController.nextPage();
                    },
                  )
                ],
                automaticallyImplyLeading: false,
              ),
        body: Stack(
          children: [
            SfPdfViewer.network(
              widget.pdf,
              controller: _pdfViewerController,
              canShowScrollHead: _showScrollHead,
              onDocumentLoadFailed: handleFailedToLoadPdf,
              // onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
              //   if (details.selectedText == null && _overlayEntry != null) {
              //     _overlayEntry!.remove();
              //     _overlayEntry = null;
              //   } else if (details.selectedText != null &&
              //       _overlayEntry == null) {
              //     _showContextMenu(context, details);
              //   }
              // },
              enableTextSelection: false,
            ),
            Visibility(
              visible: _textSearchKey.currentState?._showToast ?? false,
              child: Center(
                child: Txt(
                  AppLocalizations.of(context)!.noSearchResutFound,
                  style: TxtStyle()
                    ..textAlign.center()
                    ..padding(horizontal: 10, vertical: 8)
                    ..borderRadius(all: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleFailedToLoadPdf(PdfDocumentLoadFailedDetails e) {
    errorLoadingPDF = true;
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
          if (kDebugMode) print('failed to load ad');
        },
      ),
    );
  }
}

typedef SearchTapCallback = void Function(Object item);

class SearchToolbar extends StatefulWidget {
  const SearchToolbar({
    this.controller,
    this.onTap,
    this.showTooltip = true,
    Key? key,
  }) : super(key: key);

  final bool showTooltip;

  final PdfViewerController? controller;

  final SearchTapCallback? onTap;

  @override
  SearchToolbarState createState() => SearchToolbarState();
}

class SearchToolbarState extends State<SearchToolbar> {
  int _searchTextLength = 0;

  /// Indicates whether search toolbar items need to be shown or not.
  var _showItem = false;

  /// Indicates whether search toast need to be shown or not.
  var _showToast = false;

  /// Indicates whether search is going on.
  var _isSearching = false;

  ///An object that is used to retrieve the current value of the TextField.
  final _editingController = TextEditingController();

  /// An object that is used to retrieve the text search result.
  var _pdfTextSearchResult = PdfTextSearchResult();

  ///An object that is used to obtain keyboard focus and to handle keyboard events.
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    focusNode?.requestFocus();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focusNode?.dispose();
    super.dispose();
  }

  ///Clear the text search result
  void clearSearch() {
    _pdfTextSearchResult.clear();
  }

  ///Display the Aleint _searchTextLength = 0;rt dialog to search from the beginning
  void _showSearchAlertDialog(BuildContext context) {
    if (Platform.isIOS) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(AppLocalizations.of(context)!.search),
              content: Text(AppLocalizations.of(context)!.noMoreResult),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    setState(() {
                      _pdfTextSearchResult.nextInstance();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Txt(
                    AppLocalizations.of(context)!.yes,
                    style: TxtStyle()
                      ..fontFamily('Roboto')
                      ..fontWeight(FontWeight.w500),
                  ),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    setState(() {
                      _pdfTextSearchResult.clear();
                      _editingController.clear();
                      _showItem = false;
                      focusNode?.requestFocus();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Txt(
                    AppLocalizations.of(context)!.no,
                    style: TxtStyle()
                      ..fontFamily('Roboto')
                      ..fontWeight(FontWeight.w500),
                  ),
                ),
              ],
            );
          });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.search),
            content: Text(AppLocalizations.of(context)!.noMoreResult),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _pdfTextSearchResult.nextInstance();
                  });
                  Navigator.of(context).pop();
                },
                child: Txt(
                  AppLocalizations.of(context)!.yes,
                  style: TxtStyle()
                    ..fontFamily('Roboto')
                    ..fontWeight(FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _pdfTextSearchResult.clear();
                    _editingController.clear();
                    _showItem = false;
                    focusNode?.requestFocus();
                  });
                  Navigator.of(context).pop();
                },
                child: Txt(
                  AppLocalizations.of(context)!.no,
                  style: TxtStyle()
                    ..fontFamily('Roboto')
                    ..fontWeight(FontWeight.w500),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
          onPressed: () {
            widget.onTap?.call('Cancel Search');
            _editingController.clear();
            _pdfTextSearchResult.clear();
          },
        ),
        Flexible(
          child: TextFormField(
            style: const TextStyle(fontSize: 16),
            enableInteractiveSelection: false,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            controller: _editingController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Find...',
            ),
            onChanged: (text) {
              if (_searchTextLength < _editingController.value.text.length) {
                setState(() {});
                _searchTextLength = _editingController.value.text.length;
              }
              if (_editingController.value.text.length < _searchTextLength) {
                setState(() {
                  _showItem = false;
                });
              }
            },
            onFieldSubmitted: (String value) async {
              setState(() {
                _isSearching = true;
              });
              if (_editingController.value.text.isNotEmpty) {
                _pdfTextSearchResult = await widget.controller!
                    .searchText(_editingController.text);

                if (_pdfTextSearchResult.totalInstanceCount == 0) {
                  widget.onTap?.call('noResultFound');
                } else {
                  setState(() {
                    _showItem = true;
                  });
                }
              }
              setState(() {
                _isSearching = false;
              });
            },
          ),
        ),
        Visibility(
          visible: _isSearching,
          child: const CircularProgressIndicator(strokeWidth: 3),
        ),
        Visibility(
          visible: _editingController.text.isNotEmpty,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(
                _isSearching ? Icons.abc : Icons.clear,
                color: const Color.fromRGBO(0, 0, 0, 0.54),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _editingController.clear();
                  _pdfTextSearchResult.clear();
                  widget.controller!.clearSelection();
                  _showItem = false;
                  focusNode!.requestFocus();
                });
                widget.onTap!.call('Clear Text');
              },
              tooltip: widget.showTooltip ? 'Clear Text' : null,
            ),
          ),
        ),
        Visibility(
          visible: _showItem,
          child: Row(
            children: [
              Text(
                '${_pdfTextSearchResult.currentInstanceIndex}',
                style: TextStyle(
                    color:
                        const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
                    fontSize: 16),
              ),
              Text(
                ' ${AppLocalizations.of(context)!.localOf.toLowerCase()} ',
                style: TextStyle(
                    color:
                        const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
                    fontSize: 16),
              ),
              Text(
                '${_pdfTextSearchResult.totalInstanceCount}',
                style: TextStyle(
                    color:
                        const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
                    fontSize: 16),
              ),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(
                    Icons.navigate_before,
                    color: Color.fromRGBO(0, 0, 0, 0.54),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _pdfTextSearchResult.previousInstance();
                    });
                    widget.onTap!.call('Previous Instance');
                  },
                  tooltip: widget.showTooltip ? 'Previous' : null,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(
                    Icons.navigate_next,
                    color: Color.fromRGBO(0, 0, 0, 0.54),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_pdfTextSearchResult.currentInstanceIndex ==
                              _pdfTextSearchResult.totalInstanceCount &&
                          _pdfTextSearchResult.currentInstanceIndex != 0 &&
                          _pdfTextSearchResult.totalInstanceCount != 0) {
                        _showSearchAlertDialog(context);
                      } else {
                        widget.controller!.clearSelection();
                        _pdfTextSearchResult.nextInstance();
                      }
                    });
                    widget.onTap!.call('Next Instance');
                  },
                  tooltip: widget.showTooltip ? 'Next' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
