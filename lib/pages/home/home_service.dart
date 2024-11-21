import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:finance_tracker/helper/formatter.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:finance_tracker/reusables/notifyer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

Future<void> fetchLaporan(
  BuildContext context,
  Map<String, dynamic> filter,
  void Function(dynamic) callback,
) async {
  final repository = LaporanRepository();
  final laporans = await repository.index(filter: filter);
  callback(laporans);
}

Future<void> importDataFromCSV(
  BuildContext context,
  LaporanRepository repository,
  void Function() afterImportCallback,
) async {
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
      await repository.importData(laporans);
      afterImportCallback();
    } catch (e) {
      notify(context, NotifySeverity.error, message: 'Gagal import data');
    }

    notify(context, NotifySeverity.success, message: 'Berhasil import data');
  } else {
    notify(context, NotifySeverity.error, message: 'Gagal import data');
  }
}

exportDataToCSV(BuildContext context,
    {bool beforeImport = false, List<dynamic>? laporans}) async {
  if (laporans == null) {
    final repository = LaporanRepository();
    await repository.index().then((value) {
      laporans = value['laporanList'];
    });
  }

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

  for (var laporan in laporans!) {
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
      ? notify(
          context,
          NotifySeverity.success,
          message: 'Berhasil export data',
        )
      : null;
}

Future<String> downloadImage(LaporanHiveModel laporan, BuildContext context,
    {bool doNotify = false}) async {
  final directory = Platform.isAndroid
      ? Directory('/storage/emulated/0/Download')
      : await getApplicationDocumentsDirectory();

  final path =
      '${directory.path}/${laporan.category}-${formatDate(laporan.date)}.png';
  final file = File(path);
  await file.writeAsBytes(laporan.image!);
  if (doNotify) {
    notify(context, NotifySeverity.success,
        message: 'Gambar disimpan di $path');
  }
  return path;
}
