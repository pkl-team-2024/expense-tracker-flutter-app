import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountAlertDialog extends StatefulWidget {
  final double initialAmount;
  final Function(double) onAmountSelected;
  final String category;

  AmountAlertDialog({
    required this.initialAmount,
    required this.onAmountSelected,
    required this.category,
  });

  @override
  _AmountAlertDialogState createState() => _AmountAlertDialogState();
}

class _AmountAlertDialogState extends State<AmountAlertDialog> {
  double _selectedAmount = 0.0;
  final List<double> _commonAmounts = [100000, 50000, 20000, 10000, 5000];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.initialAmount;
    _controller.text = _selectedAmount.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Masukkan total ${widget.category}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefix: Text('Rp '),
              labelText: 'Enter amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _selectedAmount = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _commonAmounts
                  .map(
                    (amount) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAmount = amount;
                            _controller.text = amount.toString();
                          });
                        },
                        child: Text(formatRupiah(amount)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAmountSelected(_selectedAmount);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  String formatRupiah(double amount) {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }
}
