import 'package:flutter/material.dart';

class CustomCategoryDrawer extends StatefulWidget {
  final String initialCategory;
  final Function(String) onCategorySelected;
  final String laporanType;
  final List<String> possibleKategori;

  CustomCategoryDrawer({
    required this.initialCategory,
    required this.onCategorySelected,
    required this.laporanType,
    required this.possibleKategori,
  });

  @override
  _CustomCategoryDrawerState createState() => _CustomCategoryDrawerState();
}

class _CustomCategoryDrawerState extends State<CustomCategoryDrawer> {
  late String _selectedCategory;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    double minChildSize = 0.2;
    double maxChildSize = 0.8;
    double initialChildSize = ((widget.possibleKategori.length * 0.06 + 0.04))
        .clamp(minChildSize, maxChildSize);

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.only(
            top: 12.0,
            left: 8.0,
            right: 8.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 5.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14.0),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.possibleKategori.length,
                  itemBuilder: (BuildContext context, int index) {
                    String category = widget.possibleKategori[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        widget.onCategorySelected(category);

                        if (_isNavigating) return;
                        _isNavigating = true;

                        Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: _selectedCategory == category
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: _selectedCategory == category
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _selectedCategory == category
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
