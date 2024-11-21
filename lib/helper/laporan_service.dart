import 'package:finance_tracker/models/laporan_model.dart';

double getAmount(int? month, List<dynamic> laporans) {
  var laporan = month == null
      ? laporans
      : laporans.where((laporan) => laporan.date.month == month);
  double getFoldAmount(laporan) {
    return laporan.fold(0.0, (sum, laporan) => sum + laporan.amount);
  }

  return getFoldAmount(laporan.where((laporan) => laporan.isIncome)) -
      getFoldAmount(laporan.where((laporan) => !laporan.isIncome));
}
