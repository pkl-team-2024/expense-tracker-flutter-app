import 'package:finance_tracker/helper/theme_changer.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(LaporanHiveModelAdapter());
  await Hive.openBox<LaporanHiveModel>('laporanBox');
  await initializeDateFormatting();
  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Saving',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.greenAccent, brightness: Brightness.dark),
          ),
          themeMode: themeProvider.themeMode,
          home: const Home(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
