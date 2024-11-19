// TODO: kayaknya ini keuangan bukan bulan ini tapi seluruhnya

// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:finance_tracker/components/drawer.dart';
import 'package:finance_tracker/components/snackbar.dart';
import 'package:finance_tracker/helper/theme_changer.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/laporan_input.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LaporanRepository _repository = LaporanRepository();
  List<LaporanHiveModel> _laporans = [];
  List<LaporanHiveModel>? _laporansFiltered;
  final Map<String, dynamic> _currentActiveFilter = {
    'laporan_type': '',
    'category': '',
    'date-range': '',
    'imageOnly': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchLaporan(context);
  }

  @override
  Widget build(BuildContext context) {
    var thisMonth = DateTime.now().month;
    double thisMonthAmount = getAmount(thisMonth);
    double allAmount = getAmount(null);
    Map<String, int> categoryAmountMap = getCategoryGroupedAmount(_laporans);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          buildImportExport(context),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () {
                  themeProvider
                      .toggleTheme(themeProvider.themeMode == ThemeMode.light);
                },
                icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.white),
              );
            },
          ),
        ],
        title: const Column(
          children: [
            Row(
              children: [
                Text(
                  'Finance AMK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primaryContainer,
      body: _laporans.isEmpty
          ? buildNoDataScreen()
          : Column(
              children: [
                buildOverview(thisMonthAmount, allAmount),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  await modalBottomSheetComponent(
                                    context: context,
                                    child: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 16),
                                          InkWell(
                                            onTap: () async {
                                              DateTimeRange? picked =
                                                  await showDateRangePicker(
                                                context: context,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime.now(),
                                              );
                                              if (picked != null) {
                                                setFilter('date-range', picked);
                                                setState(() {});
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Pilih Tanggal',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _currentActiveFilter[
                                                                    'date-range'] !=
                                                                ''
                                                            ? DateFormat(
                                                                        'dd MMM')
                                                                    .format(_currentActiveFilter[
                                                                            'date-range']
                                                                        .start) +
                                                                ' - ' +
                                                                DateFormat(
                                                                        'dd MMM')
                                                                    .format(_currentActiveFilter[
                                                                            'date-range']
                                                                        .end)
                                                            : '',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (_currentActiveFilter[
                                                              'date-range'] !=
                                                          '') {
                                                        setFilter(
                                                            'date-range', '');
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: Icon(
                                                      _currentActiveFilter[
                                                                  'date-range'] !=
                                                              ''
                                                          ? Icons.cancel
                                                          : CupertinoIcons
                                                              .calendar,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          InkWell(
                                            onTap: () async {
                                              setFilter(
                                                  'imageOnly',
                                                  !_currentActiveFilter[
                                                      'imageOnly']);
                                              setState(() {});
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Hanya Data Bergambar',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Icon(
                                                    _currentActiveFilter[
                                                            'imageOnly']
                                                        ? Icons.check_box
                                                        : Icons
                                                            .check_box_outline_blank,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildSelectButton(
                                                _currentActiveFilter[
                                                    'laporan_type'],
                                                'Pemasukan',
                                                (value) {
                                                  setFilter(
                                                      'laporan_type',
                                                      _currentActiveFilter[
                                                                  'laporan_type'] ==
                                                              value
                                                          ? ''
                                                          : value);
                                                  setState(() {});
                                                },
                                                Colors.green,
                                                Icons.arrow_downward_rounded,
                                              ),
                                              SizedBox(width: 8),
                                              buildSelectButton(
                                                _currentActiveFilter[
                                                    'laporan_type'],
                                                'Pengeluaran',
                                                (value) {
                                                  setFilter(
                                                      'laporan_type',
                                                      _currentActiveFilter[
                                                                  'laporan_type'] ==
                                                              value
                                                          ? ''
                                                          : value);
                                                  setState(() {});
                                                },
                                                Colors.red,
                                                Icons.arrow_upward_rounded,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }),
                                  );
                                },
                                icon: const Icon(
                                    CupertinoIcons.slider_horizontal_3),
                                label: const Text('Filter'),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      categoryAmountMap.keys.length,
                                      (index) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: InkWell(
                                            onTap: () {
                                              if (_currentActiveFilter[
                                                      'category'] ==
                                                  categoryAmountMap.keys
                                                      .elementAt(index)
                                                      .toString()) {
                                                setFilter('category', '');
                                              } else {
                                                setFilter(
                                                    'category',
                                                    categoryAmountMap.keys
                                                        .elementAt(index));
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _currentActiveFilter[
                                                            'category'] ==
                                                        categoryAmountMap.keys
                                                            .elementAt(index)
                                                            .toString()
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    categoryAmountMap.keys
                                                        .elementAt(index),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    categoryAmountMap[
                                                            categoryAmountMap
                                                                .keys
                                                                .elementAt(
                                                                    index)]!
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _laporansFiltered == null
                                  ? _laporans.length
                                  : _laporansFiltered!.length,
                              itemBuilder: (context, index) {
                                final laporan = _laporansFiltered == null
                                    ? _laporans[index]
                                    : _laporansFiltered![index];
                                return Padding(
                                  padding: index ==
                                          (_laporansFiltered == null
                                              ? _laporans.length - 1
                                              : _laporansFiltered!.length - 1)
                                      ? const EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                        )
                                      : const EdgeInsets.only(
                                          top: 4,
                                          bottom: 0,
                                        ),
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        isDismissible: true,
                                        builder: (BuildContext context) {
                                          return buildLaporanDrawer(
                                              context, laporan);
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 80,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: laporan.isIncome == true
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      laporan.isIncome == true
                                                          ? Icons
                                                              .arrow_downward_rounded
                                                          : Icons
                                                              .arrow_upward_rounded,
                                                      color: laporan.isIncome ==
                                                              true
                                                          ? Colors.green
                                                          : Colors.red,
                                                      size: 38,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      laporan.category,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      formatRupiah(
                                                          laporan.amount),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  laporan.image == null
                                                      ? 'Tanpa gambar'
                                                      : 'Dengan gambar',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('dd MMM yyyy')
                                                      .format(laporan.date),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        onPressed: () async {
          bool? shouldRefresh = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => LaporanInput()));

          shouldRefresh ??= true;

          if (shouldRefresh) {
            _fetchLaporan(context);
          }
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Center buildNoDataScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.money_dollar,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            Text(
              'Belum ada data',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconButton buildImportExport(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          final Map<String, Function> operations = {
            'Import Data': () async {
              await importDataFromCSV(_repository);
            },
            'Export Data': () async {
              await exportDataToCSV(_laporans, beforeImport: false);
            },
            'Cancel': () {},
          };

          String operation = await modalBottomSheetComponent(
                context: context,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: operations.keys.length,
                      itemBuilder: (context, index) {
                        final operation = operations.keys.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(operation);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 8,
                            ),
                            child: Text(operation,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ) ??
              'Cancel';

          operations[operation]!();
        } catch (e) {
          showSimpleNotification(
            Text('Gagal: $e'),
            background: Colors.red,
            duration: const Duration(milliseconds: 1000),
          );
        }
      },
      icon: const Icon(
        CupertinoIcons.folder_solid,
        color: Colors.white,
      ),
    );
  }

  Padding buildOverview(double thisMonthAmount, double allAmount) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: 36,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Total Keuangan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatRupiah(allAmount),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Bulan ini:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                formatRupiah(thisMonthAmount),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector buildLaporanDrawer(
      BuildContext context, LaporanHiveModel laporan) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 5.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    laporan.image != null
                        ? buildLaporanPreviewImage(laporan)
                        : buildLaporanPreviewNoImage(context),
                    const SizedBox(height: 16),
                    buildLaporanPreviewData(context, laporan),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              bool shouldRefresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LaporanInput(
                                        laporan: laporan,
                                      ),
                                    ),
                                  ) ??
                                  false;
                              if (shouldRefresh) {
                                Navigator.of(context).pop();
                                _fetchLaporan(context);
                              }
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              bool shouldDelete = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Hapus Laporan'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus laporan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete) {
                                await _repository.delete(laporan.id);
                                _fetchLaporan(context);
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              'Hapus',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildLaporanPreviewData(
      BuildContext context, LaporanHiveModel laporan) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  laporan.category,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jumlah',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatRupiah(laporan.amount),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(laporan.date),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildLaporanPreviewNoImage(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Tanpa gambar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildLaporanPreviewImage(LaporanHiveModel laporan) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
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
                      final directory = Platform.isAndroid
                          ? Directory('/storage/emulated/0/Download')
                          : await getApplicationDocumentsDirectory();

                      final path =
                          '${directory.path}/${laporan.category}-${DateFormat('yyyyMMdd_HHmmss').format(laporan.date)}.png';
                      final file = File(path);
                      await file.writeAsBytes(laporan.image!);

                      showSimpleNotification(
                        Text('Gambar berhasil diexport ke $path'),
                        background: Colors.green,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchLaporan(BuildContext context) async {
    final List<LaporanHiveModel> laporans = await _repository.index();
    setState(() {
      _laporans = laporans;
    });
  }

  String formatRupiah(double amount) {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }

  double getAmount(int? month) {
    var laporan = month == null
        ? _laporans
        : _laporans.where((laporan) => laporan.date.month == month);
    double getFoldAmount(laporan) {
      return laporan.fold(0.0, (sum, laporan) => sum + laporan.amount);
    }

    return getFoldAmount(laporan.where((laporan) => laporan.isIncome)) -
        getFoldAmount(laporan.where((laporan) => !laporan.isIncome));
  }

  double getPercentageDifference(double amountByMonth, double amountByMonth2) {
    if (amountByMonth2 == 0) {
      return double.nan;
    }
    if (amountByMonth == 0) {
      return amountByMonth2 < 0 ? -100 : 100 * amountByMonth2.abs();
    }
    double difference = amountByMonth - amountByMonth2;
    double percentageDifference = (difference / amountByMonth2) * 100;
    return percentageDifference;
  }

  exportDataToCSV(List<LaporanHiveModel> laporans,
      {bool beforeImport = false}) async {
    final List<List<String>> rows = [];

    rows.add([
      'ID',
      'Category',
      'Amount',
      'Date',
      'IsIncome',
      'Image',
      'ImageName',
    ]);

    for (var laporan in laporans) {
      rows.add([
        laporan.id,
        laporan.category,
        laporan.amount.toString(),
        laporan.date.toIso8601String(),
        laporan.isIncome ? 'True' : 'False',
        laporan.image != null ? base64Encode(laporan.image!) : 'No Data',
        laporan.imageName ?? 'No Data',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
    final dateTime = DateTime.now();
    final formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(dateTime);
    final path =
        '${directory.path}/laporan_data_$formattedDateTime${beforeImport ? '_before_import' : ''}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    !beforeImport
        ? showSimpleNotification(
            Text('Data berhasil diexport ke $path'),
            background: Colors.green,
            duration: const Duration(milliseconds: 1000),
          )
        : null;
  }

  Future<void> importDataFromCSV(LaporanRepository repository) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: 'Pilih file CSV',
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvString = await file.readAsString();

      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);
      csvTable.removeAt(0);

      final List<LaporanHiveModel> laporans = [];
      for (var row in csvTable) {
        final laporan = LaporanHiveModel(
          id: row[0],
          category: row[1],
          amount: row[2] is String ? double.parse(row[2]) : row[2],
          date: DateTime.parse(row[3]),
          isIncome: row[4] == 'True',
          image: row[5] != 'No Data' ? base64Decode(row[5]) : null,
          imageName: row[6] != 'No Data' ? row[6] : null,
        );

        laporans.add(laporan);
      }

      try {
        await exportDataToCSV(laporans, beforeImport: true);
        await repository.importData(laporans);
        _fetchLaporan(context);
      } catch (e) {
        showSimpleNotification(
          Text('Gagal import data: $e'),
          background: Colors.red,
          duration: const Duration(milliseconds: 1000),
        );
      }

      showSimpleNotification(
        const Text('Data berhasil diimport'),
        background: Colors.green,
        duration: const Duration(milliseconds: 1000),
      );
    } else {
      showSimpleNotification(
        const Text('Gagal memilih file'),
        background: Colors.red,
        duration: const Duration(milliseconds: 1000),
      );
    }
  }

  List<String> getAvailableCategory(List<LaporanHiveModel> laporans) {
    return laporans.map((laporan) => laporan.category).toSet().toList();
  }

  Map<String, int> getCategoryGroupedAmount(List<LaporanHiveModel> laporans) {
    Map<String, int> categoryAmount = {};
    for (var laporan in laporans) {
      if (categoryAmount.containsKey(laporan.category)) {
        categoryAmount[laporan.category] =
            categoryAmount[laporan.category]! + 1;
      } else {
        categoryAmount[laporan.category] = 1;
      }
    }
    return categoryAmount;
  }

  void setFilter(String category, dynamic value) {
    setState(() {
      _currentActiveFilter[category] = value;
      _laporansFiltered = getFilteredLaporan(_laporans, _currentActiveFilter);
    });
  }

  Expanded buildSelectButton(String selectedValue, String value,
      void Function(String) onChanged, Color color, IconData icon) {
    return Expanded(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: Platform.isWindows ? 50 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            0,
            selectedValue == value ? -2 : 0,
            0,
          ),
          child: TextButton(
            onPressed: () {
              onChanged(value);
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(
                selectedValue == value ? color : color.withOpacity(0.1),
              ),
              foregroundColor: WidgetStateProperty.all(
                selectedValue == value ? Colors.white : color,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LaporanHiveModel>? getFilteredLaporan(List<LaporanHiveModel> laporans,
      Map<String, dynamic> currentActiveFilter) {
    return laporans.where((laporan) {
      if (currentActiveFilter['laporan_type'] != '' &&
          (currentActiveFilter['laporan_type'] == 'Pemasukan' &&
                  !laporan.isIncome ||
              currentActiveFilter['laporan_type'] == 'Pengeluaran' &&
                  laporan.isIncome)) {
        return false;
      }

      if (currentActiveFilter['category'] != '' &&
          laporan.category != currentActiveFilter['category']) {
        return false;
      }

      if (currentActiveFilter['date-range'] != '' &&
          (laporan.date.isBefore(currentActiveFilter['date-range'].start) ||
              laporan.date.isAfter(currentActiveFilter['date-range'].end))) {
        return false;
      }

      if (currentActiveFilter['imageOnly'] && laporan.image == null) {
        return false;
      }

      return true;
    }).toList();
  }
}
