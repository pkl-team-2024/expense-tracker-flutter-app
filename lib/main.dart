import 'package:finance_tracker/helper/theme_changer.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(LaporanHiveModelAdapter());
  await Hive.openBox<LaporanHiveModel>('laporanBox');
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.themeMode,
          home: const Home(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
