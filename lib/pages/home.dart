// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:io';
import 'dart:typed_data';

import 'package:finance_tracker/helper/theme_changer.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/laporan_input.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const Map<String, IconData> _tabs = {
    'Home': Icons.home,
    'Settings': Icons.settings,
    'Profile': Icons.account_circle,
    'Notifications': Icons.notifications,
  };

  final LaporanRepository _repository = LaporanRepository();
  List<LaporanHiveModel> _laporans = [];

  @override
  void initState() {
    super.initState();
    _fetchLaporan(context);
  }

  @override
  Widget build(BuildContext context) {
    var thisMonth = DateTime.now().month;
    double thisMonthAmount = getAmountByMonth(thisMonth);
    double lastMonthAmount = getAmountByMonth(thisMonth - 1);
    double percentageDifference =
        getPercentageDifference(thisMonthAmount, lastMonthAmount);
    bool isPositive = percentageDifference > 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
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
                  'Saving',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.money_dollar,
                      color: Colors.white.withOpacity(0.5),
                      size: 120,
                    ),
                    Text(
                      'Belum ada data',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                buildOverview(
                    thisMonthAmount, isPositive, percentageDifference),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 8, right: 8),
                      child: ListView.builder(
                        itemCount: _laporans.length,
                        itemBuilder: (context, index) {
                          final laporan = _laporans[index];
                          return Padding(
                            padding: index == _laporans.length - 1
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
                                    return buildLaporanDrawer(context, laporan);
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
                                                color: laporan.isIncome == true
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 48,
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
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                formatRupiah(laporan.amount),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w500,
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
          bool? shouldRefresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LaporanInput()));

          shouldRefresh ??= false;

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

  Padding buildOverview(
      double thisMonthAmount, bool isPositive, double percentageDifference) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Keuangan Bulan Ini',
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
                formatRupiah(thisMonthAmount),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isPositive
                  ? Colors.green.withOpacity(0.8)
                  : Colors.red.withOpacity(0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: 4,
              ),
              child: Text(
                percentageDifference.isFinite
                    ? (isPositive ? '+' : '-') +
                        percentageDifference.abs().toStringAsFixed(1) +
                        '% Dari bulan lalu'
                    : 'Tidak ada data bulan lalu',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
                        ? buildLaporanPreview(laporan)
                        : const Text('')
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLaporanPreview(LaporanHiveModel laporan) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16, top: 16),
          padding: const EdgeInsets.only(
            left: 16,
            right: 8,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          height: 300,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                laporan.image!,
                fit: BoxFit.fitWidth,
              ),
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

  double getAmountByMonth(int month) {
    var laporan = _laporans.where((laporan) => laporan.date.month == month);
    double getFoldAmount(laporan) {
      return laporan.fold(0.0, (sum, laporan) => sum + laporan.amount);
    }

    return getFoldAmount(laporan.where((laporan) => laporan.isIncome)) -
        getFoldAmount(laporan.where((laporan) => !laporan.isIncome));
  }

  double getPercentageDifference(double amountByMonth, double amountByMonth2) {
    return ((amountByMonth - amountByMonth2) / amountByMonth2) * 100;
  }
}
