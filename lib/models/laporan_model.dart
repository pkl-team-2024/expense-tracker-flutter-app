import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'laporan_model.g.dart';

@HiveType(typeId: 0)
class LaporanHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  bool isIncome;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  double amount;

  @HiveField(5)
  Uint8List? image;

  @HiveField(6)
  String? imageName;

  LaporanHiveModel({
    required this.id,
    required this.isIncome,
    required this.category,
    required this.date,
    required this.amount,
    this.image,
    this.imageName,
  });
}
