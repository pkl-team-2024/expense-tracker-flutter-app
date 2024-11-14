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

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    double minChildSize = 0.2;
    double maxChildSize = 0.8;
    double initialChildSize = ((widget.possibleKategori.length * 0.09))
        .clamp(minChildSize, maxChildSize);

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.only(
            top: 16.0,
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
              const SizedBox(height: 12.0),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.possibleKategori.length,
                  itemBuilder: (BuildContext context, int index) {
                    String category = widget.possibleKategori[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                      ),
                      title: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: _selectedCategory == category
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        widget.onCategorySelected(category);
                        Navigator.of(context).pop();
                      },
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
