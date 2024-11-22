import 'package:intl/intl.dart';

String formatRupiah(double amount) {
  final NumberFormat formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  return formatter.format(amount);
}

String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
  return DateFormat(format, 'id').format(date);
}

enum cropTextType { left, right }

String cropText(String text,
    {int length = 20,
    bool useEllipsis = true,
    String noDataText = 'No Data',
    cropTextType type = cropTextType.right}) {
  if (text.length > length) {
    if (type == cropTextType.right) {
      return '${text.substring(0, length)}${useEllipsis ? '...' : ''}';
    } else {
      return '${useEllipsis ? '...' : ''}${text.substring(text.length - length)}';
    }
  }
  return text ?? noDataText;
}

// ignore: constant_identifier_names
enum FileSizeUnit { B, KB, MB, GB, TB }

Map<FileSizeUnit, int> fileSizeUnitMap = {
  FileSizeUnit.B: 0,
  FileSizeUnit.KB: 1,
  FileSizeUnit.MB: 2,
  FileSizeUnit.GB: 3,
  FileSizeUnit.TB: 4,
};

String getFileSize(double size, {FileSizeUnit unit = FileSizeUnit.B}) {
  double threshold = 1024.0;
  if (size < threshold) {
    return '${size.toStringAsFixed(2)} ${unit.toString().split('.').last}';
  }
  return getFileSize(size / threshold,
      unit: FileSizeUnit.values[fileSizeUnitMap[unit]! + 1]);
}
