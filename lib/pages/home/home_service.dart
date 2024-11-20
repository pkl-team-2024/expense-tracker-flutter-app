import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:flutter/material.dart';

Future<void> fetchLaporan(
  BuildContext context,
  Map<String, dynamic> filter,
  void Function(dynamic) callback,
) async {
  final repository = LaporanRepository();
  final laporans = await repository.index(filter: filter);
  callback(laporans);
}
