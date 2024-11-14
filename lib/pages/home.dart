import 'package:finance_tracker/helper/theme_changer.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/laporan_input.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 16),
                child: IconButton(
                  onPressed: () {
                    themeProvider.toggleTheme(
                        themeProvider.themeMode == ThemeMode.light);
                  },
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              );
            },
          )
        ],
        title: const Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                  'Saving',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Icon(Icons.account_balance_wallet),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: _laporans.isEmpty
            ? const Text('No data available')
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _laporans.length,
                  itemBuilder: (context, index) {
                    final laporan = _laporans[index];
                    return Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: laporan.isIncome == true
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      laporan.isIncome == true
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      color: laporan.isIncome == true
                                          ? Colors.green
                                          : Colors.red,
                                      size: 48,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                    );
                  },
                ),
              ),
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
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final tab in _tabs.keys)
              Expanded(
                child: SizedBox(
                  height: double.infinity,
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigating to $tab'),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    icon: Icon(
                      _tabs[tab],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
}
