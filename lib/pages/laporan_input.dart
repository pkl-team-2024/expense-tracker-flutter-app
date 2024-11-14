import 'dart:io';
import 'dart:typed_data';
import 'package:finance_tracker/components/amount_input.dart';
import 'package:finance_tracker/components/category_drawer.dart';
import 'package:finance_tracker/components/snackbar.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanInput extends StatefulWidget {
  const LaporanInput({super.key});

  @override
  State<LaporanInput> createState() => _LaporanInputState();
}

class _LaporanInputState extends State<LaporanInput> {
  final LaporanRepository _repository = LaporanRepository();

  final Map<String, dynamic> _laporan = {
    'laporanType': _possibleLaporanType[0],
    'category': _possibleKategori[_possibleLaporanType[0]]![0],
    'date': DateTime.now(),
    'amount': 0.0,
    'isIncome': true,
  };

  File? _selectedImage;
  String _selectedImageName = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final compressedImage = await _compressImage(File(image.path));

      if (compressedImage != null) {
        final compressedFile = File('${image.path}_compressed.jpg')
          ..writeAsBytesSync(compressedImage);

        setState(() {
          _selectedImage = compressedFile;
          _selectedImageName = image.name;
        });
      } else {
        ShowSnackBar().show(context, 'Gambar tidak dapat dikompres');
      }
    } else {
      ShowSnackBar().show(context, 'Gambar tidak dipilih');
    }
  }

  Future<Uint8List?> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 60,
        format: CompressFormat.jpeg);
    return result;
  }

  void changeLaporanType(String laporanType) {
    setState(() {
      _laporan['isIncome'] = laporanType == _possibleLaporanType[0];
      _laporan['laporanType'] = laporanType;
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
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            buildPreview(),
            buildImageInput(),
            buildDateInput(),
            buildAmountInput(),
            buildCategoryInput(),
            const Spacer(),
            buildLaporanTypeButton(),
            const SizedBox(height: 8),
            buildButton(
              context,
              type: 'primary',
              text: 'Submit',
              icon: Icons.send,
              onPressed: () {
                if (_laporan['amount'] == 0) {
                  ShowSnackBar().show(context, 'Jumlah tidak boleh 0');
                  return;
                }

                LaporanHiveModel laporan = LaporanHiveModel(
                  id: DateTime.now().toString(),
                  isIncome: _laporan['isIncome'],
                  category: _laporan['category'],
                  date: _laporan['date'],
                  amount: _laporan['amount'],
                  image: _selectedImage != null
                      ? Uint8List.fromList(_selectedImage!.readAsBytesSync())
                      : null,
                  imageName:
                      _selectedImageName != '' ? _selectedImageName : null,
                );
                _repository.store(laporan);
                Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 8),
            buildButton(
              context,
              type: 'secondary',
              text: 'Cancel',
              icon: Icons.close,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Container buildPreview() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _laporan['isIncome']
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _laporan['isIncome']
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: _laporan['isIncome'] ? Colors.green : Colors.red,
                      size: 48,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _laporan['category'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      formatRupiah(_laporan['amount']),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _selectedImage == null ? 'Tanpa gambar' : 'Dengan gambar',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(_laporan['date']),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String formatRupiah(double amount) {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }

  SizedBox buildButton(BuildContext context,
      {String type = 'primary',
      String text = 'Submit',
      IconData? icon = Icons.send,
      double gap = 4,
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
              SizedBox(width: icon == null ? 0 : gap),
              if (icon == null) const SizedBox(width: 8),
              if (icon != null) Icon(icon),
            ],
          ),
        ),
      ),
    );
  }

  Row buildLaporanTypeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSelectButton(
          _laporan['laporanType'],
          _possibleLaporanType[0],
          changeLaporanType,
          Colors.green,
          Icons.arrow_downward_rounded,
        ),
        const SizedBox(width: 8),
        buildSelectButton(
          _laporan['laporanType'],
          _possibleLaporanType[1],
          changeLaporanType,
          Colors.red,
          Icons.arrow_upward_rounded,
        ),
      ],
    );
  }

  Expanded buildSelectButton(String selectedValue, String value,
      void Function(String) onChanged, Color color, IconData icon) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            0,
            selectedValue == value ? -2 : 0,
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
                selectedValue == value ? color : color.withOpacity(0.1),
              ),
              foregroundColor: WidgetStateProperty.all(
                selectedValue == value ? Colors.white : color,
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

  buildDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _laporan['date'],
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _laporan['date']) {
                  setState(() {
                    _laporan['date'] = picked;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(_laporan['date']),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.calendar_today,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildImageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await _pickImage();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gambar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _selectedImage == null
                              ? 'Tanpa gambar'
                              : _selectedImageName.length > 20
                                  ? '${_selectedImageName.substring(0, 3)}...${_selectedImageName.substring(_selectedImageName.length - 15)}'
                                  : _selectedImageName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.photo,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAmountInput() {
    void onAmountSelected(double amount) {
      setState(() {
        _laporan['amount'] = amount;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AmountAlertDialog(
                      initialAmount: _laporan['amount'],
                      category: _laporan['category'],
                      onAmountSelected: onAmountSelected,
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formatRupiah(_laporan['amount']),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.money_dollar_circle,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildCategoryInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CustomCategoryDrawer(
                        initialCategory: _laporan['category'],
                        onCategorySelected: (String category) {
                          setState(() {
                            _laporan['category'] = category;
                          });
                        },
                        laporanType: _laporan['laporanType'],
                        possibleKategori:
                            _possibleKategori[_laporan['laporanType']]!,
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _laporan['category'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.square_favorites_alt,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
