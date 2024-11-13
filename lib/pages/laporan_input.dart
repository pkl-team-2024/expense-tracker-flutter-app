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
      body: ListView(
        padding: const EdgeInsets.all(16),
        reverse: true,
        children: [
          const SizedBox(
            height: 16,
          ),
          buildButton(
            context,
            type: 'secondary',
            text: 'Cancel',
            icon: Icons.close,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            height: 8,
          ),
          buildButton(
            context,
            type: 'primary',
            text: 'Submit',
            icon: Icons.send,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          buildCategoryButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  SizedBox buildButton(BuildContext context,
      {String type = 'primary',
      String text = 'Submit',
      IconData? icon = Icons.send,
      void Function()? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          onPressed != null ? onPressed() : null;
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            type == 'primary'
                ? Theme.of(context).colorScheme.inverseSurface
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.all(
            type == 'primary'
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          side: type == 'secondary'
              ? WidgetStateProperty.all(
                  BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .inverseSurface
                        .withAlpha(150),
                    width: 1,
                  ),
                )
              : null,
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
                text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: icon == null ? 0 : 4),
              if (icon == null) const SizedBox(width: 8),
              if (icon != null) Icon(icon),
            ],
          ),
        ),
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
        const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
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
