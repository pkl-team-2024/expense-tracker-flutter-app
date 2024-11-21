import 'dart:io';

import 'package:finance_tracker/helper/formatter.dart';
import 'package:finance_tracker/helper/laporan_service.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/home/home_service.dart';
import 'package:finance_tracker/pages/home/home_widget.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:finance_tracker/reusables/bottomsheet.dart';
import 'package:finance_tracker/reusables/notifyer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LaporanRepository _laporanRepository = LaporanRepository();
  List _laporanList = [];
  bool _useFilteredDataToCalculate = false;
  double _totalAmount = 0;
  double _thisMonthAmount = 0;
  List<String> _possibleCategories = [];
  bool notifierInCooldown = false;
  final Map<String, dynamic> _laporanFilter = {
    'laporan_type': '',
    'category': '',
    'date-range': '',
    'imageOnly': false,
    'sortKey': 'date',
    'sortOrder': 'desc',
  };

  bool isLaporanFilterEmpty() =>
      _laporanFilter['laporan_type'].isEmpty &&
      _laporanFilter['category'].isEmpty &&
      _laporanFilter['date-range'] == '';

  @override
  void initState() {
    super.initState();
    _fetchLaporans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: const [
          ThemeToggleButton(),
          //   DEBUG ONLY
          //   IconButton(
          //     onPressed: () {
          //       _fetchLaporans();
          //       notify(context, NotifySeverity.success,
          //           message: 'Data refreshed, length: ${_laporanList.length}');
          //     },
          //     icon: const Icon(Icons.refresh),
          //   ),
        ],
        title: const AppBarTitle(),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primaryContainer,
      body: _laporanList.isEmpty && isLaporanFilterEmpty()
          ? const Center(
              child: Text('No data',
                  style: TextStyle(fontSize: 18, color: Colors.white)))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 16),
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTotalAll(),
                          buildTotalBulanIni(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.surfaceDim
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 8,
                      right: 8,
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 2),
                        buildFilterButtons(context),
                        _laporanList.isEmpty
                            ? Expanded(
                                child: Center(
                                    child: Text('No data',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                        ))))
                            : const SizedBox(height: 8),
                        buildLaporanList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.primary
            : null,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Expanded buildLaporanList() {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.builder(
          itemCount: _laporanList.length,
          itemBuilder: (context, index) {
            final laporan = _laporanList[index];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == _laporanList.length - 1 ? 0 : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SwipeActionCell(
                  key: ObjectKey(laporan),
                  leadingActions: laporan.image != null
                      ? [
                          SwipeAction(
                            icon: const Icon(CupertinoIcons.square_arrow_down,
                                color: Colors.white),
                            onTap: (CompletionHandler handler) {
                              downloadImage(laporan, context, doNotify: true);
                              handler(false);
                            },
                            color: Colors.green,
                          ),
                        ]
                      : [],
                  trailingActions: [
                    SwipeAction(
                      nestedAction: SwipeNestedAction(title: 'Hapus?'),
                      icon: const Icon(CupertinoIcons.delete,
                          color: Colors.white),
                      onTap: (CompletionHandler handler) async {
                        await handler(true);
                        _laporanRepository.delete(laporan.id);
                        _laporanList.removeAt(index);
                        setState(() {});
                      },
                      color: Colors.red,
                    ),
                    SwipeAction(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onTap: (CompletionHandler handler) {},
                      color: Colors.orange,
                    ),
                  ],
                  child: ListTile(
                    onTap: () async {
                      if (laporan.image == null) return;
                      var screenHeight = MediaQuery.of(context).size.height;
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog.fullscreen(
                            backgroundColor: Colors.black,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: Center(
                                    child: Image.memory(
                                      laporan.image!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.download,
                                              color: Colors.white),
                                          onPressed: () async {
                                            await downloadImage(
                                                laporan, context,
                                                doNotify: true);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          laporan.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatRupiah(laporan.amount),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatDate(laporan.date),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    leading: Icon(
                      laporan.isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 32,
                    ),
                    iconColor: laporan.isIncome ? Colors.green : Colors.red,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        laporan.image != null
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.image_rounded,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 4)
                                ],
                              )
                            : const SizedBox(),
                        Text(
                          laporan.category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(formatRupiah(laporan.amount)),
                    trailing: Text(
                      formatDate(laporan.date),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container buildImagePreview(
      BuildContext context, double screenHeight, LaporanHiveModel laporan) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      height: screenHeight * 0.5,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: double.infinity,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    laporan.image!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.download),
                color: Colors.white,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.black),
                ),
                onPressed: () async {
                  String path = await downloadImage(laporan, context);

                  notify(context, NotifySeverity.success,
                      message: 'Gambar disimpan di $path');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildFilterButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(_useFilteredDataToCalculate
                ? Icons.link_off_rounded
                : Icons.link_rounded),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              setState(() {
                _useFilteredDataToCalculate = !_useFilteredDataToCalculate;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _laporanFilter['imageOnly']
                  ? Icons.image_not_supported_rounded
                  : Icons.image_rounded,
            ),
            onPressed: () {
              setState(() {
                _laporanFilter['imageOnly'] = !_laporanFilter['imageOnly'];
              });
              _fetchLaporans();
            },
          ),
          IconButton(
            icon: Icon(
              _laporanFilter['date-range'] == ''
                  ? Icons.date_range_rounded
                  : Icons.cancel,
            ),
            onPressed: () {
              if (_laporanFilter['date-range'] != '') {
                setState(() {
                  _laporanFilter['date-range'] = '';
                });
                _fetchLaporans();
                return;
              }
              showDateRangePicker(
                context: context,
                firstDate: DateTime(2021),
                lastDate: DateTime.now(),
                initialDateRange: _laporanFilter['date-range'] == ''
                    ? null
                    : DateTimeRange(
                        start: DateFormat('yyyy-MM-dd').parse(
                            _laporanFilter['date-range'].split(' - ')[0]),
                        end: DateFormat('yyyy-MM-dd').parse(
                            _laporanFilter['date-range'].split(' - ')[1]),
                      ),
              ).then((dateRange) {
                if (dateRange != null) {
                  setState(() {
                    _laporanFilter['date-range'] = dateRange;
                  });
                  _fetchLaporans();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              _laporanFilter['laporan_type'] == 'Pengeluaran'
                  ? Icons.arrow_upward
                  : _laporanFilter['laporan_type'] == 'Pemasukan'
                      ? Icons.arrow_downward
                      : Icons.swap_vert_rounded,
            ),
            color: _laporanFilter['laporan_type'] == 'Pemasukan'
                ? Colors.green
                : _laporanFilter['laporan_type'] == 'Pengeluaran'
                    ? Colors.red
                    : null,
            onPressed: () {
              switch (_laporanFilter['laporan_type']) {
                case '':
                  _laporanFilter['laporan_type'] = 'Pemasukan';
                  break;
                case 'Pemasukan':
                  _laporanFilter['laporan_type'] = 'Pengeluaran';
                  break;
                case 'Pengeluaran':
                  _laporanFilter['laporan_type'] = '';
                  break;
              }
              _fetchLaporans();
            },
          ),
          IconButton(
            onPressed: () async {
              await modalBottomSheetComponent(
                context,
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: CupertinoPicker(
                          magnification: 1.22,
                          squeeze: 1.0,
                          useMagnifier: true,
                          itemExtent: 32,
                          scrollController: FixedExtentScrollController(
                            initialItem: ['', ..._possibleCategories]
                                .indexOf(_laporanFilter['category'] ?? ''),
                          ),
                          onSelectedItemChanged: (int selectedItem) {
                            _laporanFilter['category'] =
                                ['', ..._possibleCategories][selectedItem];
                          },
                          children: ['', ..._possibleCategories]
                              .map((category) => Center(
                                    child: Text(
                                      category == '' ? 'Semua' : category,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            _laporanFilter['category'] ==
                                                    category
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              _fetchLaporans();
            },
            icon: Icon(
              _laporanFilter['category'] == ''
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_off_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return CupertinoActionSheet(
                    title: const Text('Export/Import Data'),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () async {
                          bool shouldClose = await showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return CupertinoActionSheet(
                                    title: const Text('Export Data'),
                                    message: const Text('Export seluruh data?'),
                                    actions: [
                                      CupertinoActionSheetAction(
                                          onPressed: () {
                                            exportDataToCSV(context);
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Seluruh Data')),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          exportDataToCSV(context,
                                              laporans: _laporanList);
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text(
                                            'Hanya Data Hasil Filter'),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  );
                                },
                              ) ??
                              false;
                          if (shouldClose) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Export ke CSV'),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () async {
                          importDataFromCSV(
                            context,
                            _laporanRepository,
                            () => _fetchLaporans(),
                          );
                        },
                        child: const Text('Import dari CSV'),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.file_open_rounded),
          ),
        ],
      ),
    );
  }

  Column buildTotalAll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Keuangan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          formatRupiah(_useFilteredDataToCalculate
              ? getAmount(null, _laporanList)
              : _totalAmount),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Row buildTotalBulanIni() {
    return Row(
      children: [
        const Text(
          "Bulan ini:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: 4),
        Text(
          formatRupiah(_useFilteredDataToCalculate
              ? getAmount(DateTime.now().month, _laporanList)
              : _thisMonthAmount),
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _fetchLaporans() {
    fetchLaporan(context, _laporanFilter, (laporan) {
      setState(() {
        _laporanList = laporan['laporanList'];
        _totalAmount = laporan['amount'];
        _thisMonthAmount = laporan['thisMonthAmount'];
        _possibleCategories = laporan['categoryList'];
      });
    });
  }
}
