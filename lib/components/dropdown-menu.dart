import 'package:flutter/material.dart';

class DropdownMenu extends StatefulWidget {
  final Map<String, String> items;
  final String title;
  final void Function(String?)? onChanged;
  final String? defaultValue;

  const DropdownMenu({required this.items, required this.title, this.onChanged, this.defaultValue });

  @override
  _DropdownMenuState createState() => _DropdownMenuState(defaultValue);
}

class _DropdownMenuState extends State<DropdownMenu> {
  String? selected;

  _DropdownMenuState(this.selected);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        DropdownButton<String>(
          isExpanded: true,
          value: selected,
          onChanged: (newValue) {
            setState(() {
              selected = newValue;
            });
            if (widget.onChanged != null) widget.onChanged!(newValue);
          },
          items: widget.items.entries.map((MapEntry<String, String> entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
}
