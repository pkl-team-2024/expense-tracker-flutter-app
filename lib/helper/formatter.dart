import 'package:intl/intl.dart';

String formatRupiah(double amount) {
  final NumberFormat formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  return formatter.format(amount);
}

String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
  return DateFormat(format, 'id').format(date);
}
