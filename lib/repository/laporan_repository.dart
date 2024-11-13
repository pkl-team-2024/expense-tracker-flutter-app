import 'package:finance_tracker/models/laporan_model.dart';
import 'package:hive/hive.dart';

class LaporanRepository {
  static const String _boxName = 'laporanBox';

  static Future<Box<LaporanHiveModel>> _getBox() async {
    return await Hive.openBox<LaporanHiveModel>(_boxName);
  }

  Future<List<LaporanHiveModel>> index() async {
    final box = await _getBox();
    return box.values.toList();
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
}
