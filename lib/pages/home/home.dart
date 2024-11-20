import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:finance_tracker/helper/formatter.dart';
import 'package:finance_tracker/helper/laporan_service.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/home/home_service.dart';
import 'package:finance_tracker/pages/home/home_widget.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:finance_tracker/reusables/notifyer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LaporanRepository _laporanRepository = LaporanRepository();
  List<LaporanHiveModel> _laporanList = [];
  bool _useFilteredDataToCalculate = false;
  double _totalAmount = 0;
  double _thisMonthAmount = 0;
  final Map<String, dynamic> _laporanFilter = {
    'laporan_type': '',
    'category': '',
    'date-range': '',
    'imageOnly': false,
    'sortKey': 'date',
    'sortOrder': 'desc',
  };

  bool isLaporanFilterEmpty() {
    return _laporanFilter['laporan_type'].isEmpty &&
        _laporanFilter['category'].isEmpty &&
        _laporanFilter['date-range'] == '';
  }

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
        actions: [
          const ThemeToggleButton(),
          IconButton(
            onPressed: () {
              _fetchLaporans();
              notify(context, NotifySeverity.success,
                  message: 'Data refreshed, length: ${_laporanList.length}');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        title: const AppBarTitle(),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primaryContainer,
      body: _laporanList.isEmpty && isLaporanFilterEmpty()
          ? const Center(
              child: Text(
                'No data',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Row(
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
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                formatRupiah(_useFilteredDataToCalculate
                                    ? getAmount(
                                        DateTime.now().month, _laporanList)
                                    : _thisMonthAmount),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(_useFilteredDataToCalculate
                                  ? Icons.link_off_rounded
                                  : Icons.link_rounded),
                              color: Theme.of(context).colorScheme.onSurface,
                              onPressed: () {
                                setState(() {
                                  _useFilteredDataToCalculate =
                                      !_useFilteredDataToCalculate;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(_laporanFilter['imageOnly']
                                  ? Icons.image_not_supported_rounded
                                  : Icons.image_rounded),
                              color: Theme.of(context).colorScheme.onSurface,
                              onPressed: () {
                                setState(() {
                                  _laporanFilter['imageOnly'] =
                                      !_laporanFilter['imageOnly'];
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
                              color: Theme.of(context).colorScheme.onSurface,
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
                                  initialDateRange: _laporanFilter[
                                              'date-range'] ==
                                          ''
                                      ? null
                                      : DateTimeRange(
                                          start: DateFormat('yyyy-MM-dd').parse(
                                              _laporanFilter['date-range']
                                                  .split(' - ')[0]),
                                          end: DateFormat('yyyy-MM-dd').parse(
                                              _laporanFilter['date-range']
                                                  .split(' - ')[1]),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: _laporanList.isEmpty
                        ? Center(
                            child: Text(
                              'No data',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _laporanList.length,
                            itemBuilder: (context, index) {
                              final laporan = _laporanList[index];
                              return Container(
                                margin: index > 0
                                    ? const EdgeInsets.only(top: 8)
                                    : const EdgeInsets.only(top: 0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  leading: Icon(
                                    laporan.isIncome
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 32,
                                  ),
                                  iconColor: laporan.isIncome
                                      ? Colors.green
                                      : Colors.red,
                                  title: Text(
                                    laporan.category,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(formatRupiah(laporan.amount)),
                                  trailing: Text(
                                    formatDate(laporan.date),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.surfaceBright,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  void _fetchLaporans() {
    fetchLaporan(context, _laporanFilter, (laporan) {
      setState(() {
        _laporanList = laporan['laporanList'];
        _totalAmount = laporan['amount'];
        _thisMonthAmount = laporan['thisMonthAmount'];
      });
    });
  }
}
