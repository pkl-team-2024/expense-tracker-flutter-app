import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:flutter/material.dart';

class LaporanInput extends StatefulWidget {
  const LaporanInput({super.key});

  @override
  State<LaporanInput> createState() => _LaporanInputState();
}

class _LaporanInputState extends State<LaporanInput> {
  final LaporanRepository _repository = LaporanRepository();

  final Map<String, dynamic> _laporan = {
    'laporan_type': _possibleLaporanType[0],
    'category': _possibleKategori[_possibleLaporanType[0]]![0],
    'date': DateTime.now(),
    'amount': 0.0,
  };

  void changeLaporanType(String laporanType) {
    setState(() {
      _laporan['laporan_type'] = laporanType;
      _laporan['category'] = _possibleKategori[laporanType]![0];
    });
  }

  static const List<String> _possibleLaporanType = [
    'Pemasukan',
    'Pengeluaran',
  ];
  static const Map<String, List<String>> _possibleKategori = {
    'Pemasukan': [
      'Gaji',
      'Bonus',
      'Hadiah',
      'Lainnya',
    ],
    'Pengeluaran': [
      'Makanan',
      'Transportasi',
      'Hiburan',
      'Lainnya',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Laporan Keuangan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        reverse: true,
        children: [
          SizedBox(
            height: 16,
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.inverseSurface),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Masukkan',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          buildCategoryButton()
        ],
      ),
    );
  }

  Row buildCategoryButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSelectButton(
          _laporan['laporan_type'],
          _possibleLaporanType[0],
          changeLaporanType,
          Colors.green,
          Icons.arrow_downward_rounded,
        ),
        SizedBox(width: 16),
        buildSelectButton(
          _laporan['laporan_type'],
          _possibleLaporanType[1],
          changeLaporanType,
          Colors.red,
          Icons.arrow_upward_rounded,
        ),
      ],
    );
  }

  Expanded buildSelectButton(String selected_value, String value,
      void Function(String) onChanged, Color color, IconData icon) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            0,
            selected_value == value ? -2 : 0,
            0,
          ),
          child: TextButton(
            onPressed: () {
              onChanged(value);
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(
                selected_value == value ? color : color.withOpacity(0.1),
              ),
              foregroundColor: WidgetStateProperty.all(
                selected_value == value ? Colors.white : color,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(icon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
