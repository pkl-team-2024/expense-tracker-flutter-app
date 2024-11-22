import 'dart:io';
import 'dart:typed_data';

import 'package:finance_tracker/helper/formatter.dart';
import 'package:finance_tracker/models/laporan_model.dart';
import 'package:finance_tracker/pages/input/input_service.dart';
import 'package:finance_tracker/pages/input/input_widget.dart';
import 'package:finance_tracker/repository/laporan_repository.dart';
import 'package:finance_tracker/reusables/bottomsheet.dart';
import 'package:finance_tracker/reusables/notifyer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddLaporan extends StatefulWidget {
  LaporanHiveModel? laporan;

  AddLaporan({super.key, this.laporan});

  @override
  State<AddLaporan> createState() => _AddLaporanState();
}

class _AddLaporanState extends State<AddLaporan> {
  final LaporanRepository _repository = LaporanRepository();
  bool _isEditing = false;
  final Map<String, List<double>> _commonAmountsMap = {
    'Pemasukan': [20000000, 15000000, 11000000],
    'Pengeluaran': [2000000, 1000000, 500000, 100000]
  };
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
  final Map<String, dynamic> _laporan = {
    'laporanType': _possibleKategori.keys.first,
    'category': _possibleKategori.values.first.first,
    'date': DateTime.now(),
    'amount': 0.0,
    'isIncome': true,
    'image': null,
    'imageName': null,
  };
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _changeLaporanType(String laporanType) {
    if (_laporan['laporanType'] == laporanType) {
      return;
    }
    setState(() {
      _laporan['laporanType'] = laporanType;
      _laporan['category'] = _possibleKategori[laporanType]!.first;
      _laporan['isIncome'] = laporanType == _possibleKategori.keys.first;
    });
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = _laporan['amount'].toString();
    if (widget.laporan != null) {
      final laporan = widget.laporan!;
      _isEditing = true;
      _laporan['laporanType'] = laporan.isIncome ? 'Pemasukan' : 'Pengeluaran';
      _laporan['category'] = laporan.category;
      _laporan['date'] = laporan.date;
      _laporan['amount'] = laporan.amount;
      _laporan['isIncome'] = laporan.isIncome;
      _laporan['image'] = laporan.image;
      _laporan['imageName'] = laporan.imageName ?? '';
      _amountController.text = laporan.amount.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Laporan' : 'Tambah Laporan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Column(
            children: [
              buildLaporanPreview(laporan: _laporan),
              const SizedBox(height: 8),
              buildLaporanImageSelect(context),
              const SizedBox(height: 8),
              buildAmountInput(context),
              const SizedBox(height: 8),
              buildTanggalSelectButton(context),
              const SizedBox(height: 8),
              buildKategoriSelectButton(context),
              const SizedBox(height: 8),
              buildJenisLaporanButton(),
              const SizedBox(height: 8),
              buildFullWidthButton(context, 'Submit', primary: true,
                  onButtonPressed: () {
                if (_laporan['amount'] == 0.0) {
                  notify(context, NotifySeverity.error,
                      message: 'Total tidak boleh 0');
                  return;
                }

                final laporan = LaporanHiveModel(
                  id: widget.laporan?.id ?? DateTime.now().toString(),
                  isIncome: _laporan['isIncome'],
                  category: _laporan['category'],
                  date: _laporan['date'],
                  amount: _laporan['amount'],
                  image: _laporan['image'],
                  imageName: _laporan['imageName'],
                );

                if (_isEditing) {
                  _repository.update(laporan);
                  notify(context, NotifySeverity.success,
                      message: 'Berhasil mengubah laporan');
                } else {
                  _repository.store(laporan);
                  notify(context, NotifySeverity.success,
                      message: 'Berhasil menambahkan laporan');
                }
                Navigator.of(context).pop(true);
              }),
              const SizedBox(height: 8),
              buildFullWidthButton(context, 'Cancel', primary: false,
                  onButtonPressed: () {
                Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildAmountInput(BuildContext context) {
    return buildFullWidthButton(
        context, 'Ganti Total ${_laporan['laporanType']}', icon: Icons.edit,
        onButtonPressed: () async {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
      await modalBottomSheetComponent(
        context,
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final amount = double.tryParse(value);
                if (amount != null) {
                  setState(() {
                    _laporan['amount'] = amount;
                  });
                }
                Navigator.of(context).pop();
              },
              decoration: InputDecoration(
                hintText: 'Masukkan total ${_laporan['laporanType']}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: 'Rp ',
                suffixIcon: const Icon(CupertinoIcons.money_dollar_circle),
              ),
            ),
            SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _commonAmountsMap[_laporan['laporanType']]!.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                      ),
                      onPressed: () {
                        setState(() {
                          _laporan['amount'] = e;
                          _amountController.text = e.toString();
                        });
                      },
                      child: Text(formatRupiah(e)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _laporan['amount'] =
              double.tryParse(_amountController.text) ?? _laporan['amount'];
        });
      });
    });
  }

  SizedBox buildTanggalSelectButton(BuildContext context) {
    return buildFullWidthButton(
      context,
      'Ganti Tanggal',
      icon: CupertinoIcons.calendar_badge_plus,
      onButtonPressed: () async {
        await modalBottomSheetComponent(
          context,
          child: SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _laporan['date'],
              onDateTimeChanged: (DateTime newDate) {
                _laporan['date'] = newDate;
              },
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  SizedBox buildKategoriSelectButton(BuildContext context) {
    return buildFullWidthButton(context, 'Ganti Kategori', onButtonPressed: () {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text('Pilih Kategori'),
            actions: _possibleKategori[_laporan['laporanType']]!.map((e) {
              return CupertinoActionSheetAction(
                onPressed: () {
                  setState(() {
                    _laporan['category'] = e;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(e),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          );
        },
      );
    }, icon: CupertinoIcons.square_stack_3d_up_fill);
  }

  Container buildLaporanImageSelect(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      height: 200,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          await _pickImage();
        },
        child: Center(
          child: _laporan['image'] == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.photo,
                      size: 32,
                      color: Colors.grey,
                    ),
                    Text(
                      'Klik untuk menambah gambar',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: InteractiveViewer(
                            panEnabled: true,
                            child: Image.memory(
                              _laporan['image'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cropText(_laporan['imageName'],
                                      type: cropTextType.left,
                                      noDataText: 'Tanpa Nama'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  getFileSize(
                                      _laporan['image']!.length.toDouble()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Row buildJenisLaporanButton() {
    return Row(
      children: [
        ..._possibleKategori.keys.map((e) {
          Color getBgColor(String e) {
            return e == _possibleKategori.keys.first
                ? e == _laporan['laporanType']
                    ? Colors.green
                    : Colors.green.withOpacity(0.4)
                : e == _laporan['laporanType']
                    ? Colors.red
                    : Colors.red.withOpacity(0.4);
          }

          return Expanded(
            child: Container(
              margin: e == _possibleKategori.keys.first
                  ? const EdgeInsets.only(right: 4)
                  : const EdgeInsets.only(left: 4),
              child: CupertinoButton(
                padding: const EdgeInsets.all(8),
                color: getBgColor(e),
                pressedOpacity: 0.9,
                onPressed: () {
                  _changeLaporanType(e);
                },
                child: Text(e,
                    style: TextStyle(
                        color: e == _laporan['laporanType']
                            ? Colors.white
                            : Colors.white.withOpacity(0.7))),
              ),
            ),
          );
        }),
      ],
    );
  }

  _pickImage() async {
    ImageSource? source;
    if (Platform.isAndroid || Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(_laporan['image'] == null
                ? 'Tambahkan gambar'
                : 'Ganti gambar'),
            message: const Text('Pilih sumber gambar yang akan digunakan'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  source = ImageSource.camera;
                  Navigator.of(context).pop();
                },
                child: const Text('Kamera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  source = ImageSource.gallery;
                  Navigator.of(context).pop();
                },
                child: const Text('Galeri'),
              ),
              _laporan['image'] != null
                  ? CupertinoActionSheetAction(
                      onPressed: () {
                        setState(() {
                          _laporan['image'] = null;
                          _laporan['imageName'] = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Hapus gambar'),
                    )
                  : const SizedBox(),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          );
        },
      );
    } else {
      source = ImageSource.gallery;
    }

    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(source: source!);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final compressedImage = await compressImage(file);
    if (compressedImage != null) {
      setState(() {
        _laporan['image'] = compressedImage;
        _laporan['imageName'] = file.path.split('/').last;
      });
    }
    if (mounted) {
      notify(context, NotifySeverity.success,
          message: 'Berhasil menambahkan gambar');
    }
  }
}
