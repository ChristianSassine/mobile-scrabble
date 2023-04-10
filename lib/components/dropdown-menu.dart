import 'package:flutter/material.dart';

class DropdownMenu extends StatefulWidget {
  final Map<String, String> items;
  final String title;
  final void Function(String?)? onChanged;
  String? value;

  DropdownMenu({super.key, required this.items, required this.title, this.onChanged, this.value });

  @override
  _DropdownMenuState createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {

  _DropdownMenuState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        DropdownButton<String>(
          isExpanded: true,
          value: widget.value,
          onChanged: (newValue) {
            setState(() {
              widget.value = newValue;
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
