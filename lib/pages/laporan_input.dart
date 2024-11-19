import 'dart:io';
import 'dart:typed_data';
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
  LaporanHiveModel? laporan;

  LaporanInput({super.key, this.laporan});

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
  bool _isEditing = false;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  File? _selectedImage;
  String _selectedImageName = '';

  final Map<String, List<double>> _commonAmountsMap = {
    'Pemasukan': [20000000, 15000000, 11000000],
    'Pengeluaran': [2000000, 1000000, 500000, 100000]
  };

  Future<void> _pickImage() async {
    ImageSource? source;
    if (Platform.isAndroid || Platform.isIOS) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder: (BuildContext context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNode.requestFocus();
          });
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 5.0,
                                width: 100.0,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              source = ImageSource.camera;
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt),
                                const SizedBox(width: 8),
                                Text('Kamera',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              source = ImageSource.gallery;
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.photo),
                                const SizedBox(width: 8),
                                Text('Galeri',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      source = ImageSource.gallery;
    }
    if (source == null) return;

    final ImagePicker picker = ImagePicker();
    XFile? image;

    try {
      image = await picker.pickImage(source: source!);
    } catch (e) {
      ShowSnackBar().show(context, 'Gambar tidak dapat dipilih');
    }

    if (image != null) {
      final compressedImage = Platform.isWindows
          ? File(image.path).readAsBytesSync()
          : await _compressImage(File(image.path));

      if (compressedImage != null) {
        File compressedFile = File('${image.path}_compressed.jpg')
          ..writeAsBytesSync(compressedImage);

        setState(() {
          _selectedImage = compressedFile;
          _selectedImageName = image!.name;
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
      quality: 60,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  void changeLaporanType(String laporanType) {
    setState(() {
      _laporan['isIncome'] = laporanType == _possibleLaporanType[0];
      _laporan['laporanType'] = laporanType;
      _laporan['category'] = _possibleKategori[laporanType]![0];
      _laporan['amount'] = 0.0;
    });
  }

  static const List<String> _possibleLaporanType = [
    'Pemasukan',
    'Pengeluaran',
  ];
  static const Map<String, List<String>> _possibleKategori = {
    'Pemasukan': [
      'Dana Operasional',
      'CA Project',
      'CA Lainnya',
      'Lainnya',
    ],
    'Pengeluaran': [
      'Alat Tulis Kantor',
      'Meeting',
      'Jamuan Tamu',
      'Konsumsi SPJM',
      'Konsumsi Regional',
      'Lainnya',
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller.text = _laporan['amount'].toString();

    if (widget.laporan != null) {
      final laporan = widget.laporan!;
      _laporan['laporanType'] = laporan.isIncome ? 'Pemasukan' : 'Pengeluaran';
      _laporan['category'] = laporan.category;
      _laporan['date'] = laporan.date;
      _laporan['amount'] = laporan.amount;
      _laporan['isIncome'] = laporan.isIncome;
      _selectedImage =
          laporan.image != null ? File.fromRawPath(laporan.image!) : null;
      _selectedImageName = laporan.imageName ?? '';
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Laporan'),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      buildPreview(),
                      buildImageInput(),
                      buildDateInput(),
                      buildAmountInput(),
                      buildCategoryInput(),
                      const SizedBox(height: 16),
                      buildLaporanTypeButton(),
                      const SizedBox(height: 8),
                      buildButton(
                        context,
                        type: 'primary',
                        text: 'Submit',
                        icon: Icons.send,
                        onPressed: () {
                          if (_laporan['amount'] == 0) {
                            ShowSnackBar()
                                .show(context, 'Jumlah tidak boleh 0');
                            return;
                          }

                          LaporanHiveModel laporan = LaporanHiveModel(
                            id: _isEditing
                                ? widget.laporan!.id
                                : DateTime.now().toString(),
                            isIncome: _laporan['isIncome'],
                            category: _laporan['category'],
                            date: _laporan['date'],
                            amount: _laporan['amount'],
                            image: _selectedImage != null
                                ? Uint8List.fromList(
                                    _selectedImage!.readAsBytesSync())
                                : null,
                            imageName: _selectedImageName != ''
                                ? _selectedImageName
                                : null,
                          );
                          _isEditing
                              ? _repository.update(laporan)
                              : _repository.store(laporan);
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
              )
            ],
          ),
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
                      size: 38,
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
                        fontSize: 18,
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

  Widget buildButton(BuildContext context,
      {String type = 'primary',
      String text = 'Submit',
      IconData? icon = Icons.send,
      double gap = 4,
      void Function()? onPressed}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: Platform.isWindows ? 50 : 40),
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
          child: Container(
            constraints:
                BoxConstraints(minHeight: Platform.isWindows ? 50 : 20),
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
                  isDismissible: true,
                  builder: (BuildContext context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _focusNode.requestFocus();
                    });
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {},
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 5.0,
                                          width: 100.0,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      onSubmitted: (value) {
                                        final amount = double.tryParse(value);
                                        if (amount != null) {
                                          setState(() {
                                            _laporan['amount'] = amount;
                                          });
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Jumlah',
                                        prefix: Text('Rp '),
                                        suffixIcon: Icon(
                                          CupertinoIcons.money_dollar_circle,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        final amount = double.tryParse(value);
                                        if (amount != null) {
                                          setState(() {
                                            _laporan['amount'] = amount;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _commonAmountsMap[
                                                _laporan['laporanType']]!
                                            .map(
                                              (amount) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4.0),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .inverseSurface
                                                            .withOpacity(0.05),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    formatRupiah(amount),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _laporan['amount'] =
                                                          amount;
                                                      _controller.text =
                                                          amount.toString();
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
                  isDismissible: true,
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {},
                          child: AnimatedContainer(
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
                          ),
                        ),
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
