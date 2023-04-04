import 'package:flutter/material.dart';

class ToggleIconButton extends StatefulWidget {
  final IconData on_icon, off_icon;

  const ToggleIconButton({super.key, required this.on_icon, required this.off_icon});

  @override
  _ToggleIconButtonState createState() => _ToggleIconButtonState();
}

class _ToggleIconButtonState extends State<ToggleIconButton> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isOn ? widget.off_icon : widget.on_icon),
      onPressed: () {
        setState(() {
          _isOn = !_isOn;
        });
      },
    );
  }
}
