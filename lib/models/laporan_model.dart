import 'package:hive/hive.dart';

part 'laporan_model.g.dart';

@HiveType(typeId: 0)
class LaporanHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String laporan_type;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  double amount;

  LaporanHiveModel({
    required this.id,
    required this.laporan_type,
    required this.category,
    required this.date,
    required this.amount,
  });
}
