import 'package:finance_tracker/helper/laporan_service.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:hive/hive.dart';

class LaporanRepository {
  static const String _boxName = 'laporanBox';

  static Future<Box<LaporanHiveModel>> _getBox() async {
    return await Hive.openBox<LaporanHiveModel>(_boxName);
  }

  Future<Map<String, dynamic>> index({
    Map<String, dynamic>? filter,
  }) async {
    final box = await _getBox();
    List<LaporanHiveModel> laporanList = box.values.toList();
    double amount = getAmount(null, laporanList);
    double thisMonthAmount = getAmount(DateTime.now().month, laporanList);
    List<String> categoryList =
        laporanList.map((e) => e.category).toSet().toList();
    laporanList = filterLaporan(filter, laporanList);

    return {
      'laporanList': laporanList,
      'amount': amount,
      'thisMonthAmount': thisMonthAmount,
      'categoryList': categoryList,
    };
  }

  Future<void> store(LaporanHiveModel laporan) async {
    final box = await _getBox();
    await box.put(laporan.id, laporan);
  }

  Future<void> update(LaporanHiveModel laporan) async {
    final box = await _getBox();
    if (!box.containsKey(laporan.id)) {
      throw Exception('Laporan not found');
    }
    await box.put(laporan.id, laporan);
  }

  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<void> importData(List<LaporanHiveModel> laporanList) async {
    final box = await _getBox();
    await box.clear();
    for (final laporan in laporanList) {
      await box.put(laporan.id, laporan);
    }
  }

  List<LaporanHiveModel> filterLaporan(
      Map<String, dynamic>? filter, List<LaporanHiveModel> laporanList) {
    if (filter != null) {
      if (filter['laporan_type'] != null && filter['laporan_type'].isNotEmpty) {
        bool isIncome = filter['laporan_type'] == 'Pemasukan';
        laporanList = laporanList
            .where((laporan) => laporan.isIncome == isIncome)
            .toList();
      }

      if (filter['category'] != null && filter['category'].isNotEmpty) {
        laporanList = laporanList
            .where((laporan) => laporan.category == filter['category'])
            .toList();
      }

      if (filter['date-range'] != null && filter['date-range'] != '') {
        DateTime startDate = filter['date-range'].start;
        DateTime endDate =
            filter['date-range'].end.add(const Duration(days: 1));
        laporanList = laporanList
            .where((laporan) =>
                !laporan.date.isBefore(startDate) &&
                laporan.date.isBefore(endDate))
            .toList();
      }

      if (filter['imageOnly'] != null && filter['imageOnly']) {
        laporanList =
            laporanList.where((laporan) => laporan.image != null).toList();
      }

      String sortKey = filter['sortKey'] ?? 'date';
      String sortOrder = filter['sortOrder'] ?? 'desc';

      laporanList.sort((a, b) {
        int compareResult;
        switch (sortKey) {
          case 'category':
            compareResult = a.category.compareTo(b.category);
            break;
          case 'amount':
            compareResult = a.amount.compareTo(b.amount);
            break;
          case 'date':
          default:
            compareResult = a.date.compareTo(b.date);
            break;
        }
        return sortOrder == 'asc' ? compareResult : -compareResult;
      });
    }
    return laporanList;
  }
}
