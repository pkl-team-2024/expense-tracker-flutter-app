import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/laporan_input.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:flutter/material.dart';

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
        child: _laporans.length > 0 ? null : const Text('No data available'),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LaporanInput()));
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
}
