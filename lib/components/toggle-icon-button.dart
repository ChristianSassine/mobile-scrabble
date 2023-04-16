import 'package:flutter/material.dart';

class ToggleIconButton extends StatefulWidget {
  final IconData on_icon, off_icon;
  final void Function(bool)? onChanged;
  final bool isOn;

  const ToggleIconButton(
      {super.key,
      required this.isOn,
      required this.on_icon,
      required this.off_icon,
      this.onChanged});

  @override
  _ToggleIconButtonState createState() => _ToggleIconButtonState();
}

class _ToggleIconButtonState extends State<ToggleIconButton> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.isOn;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isOn ? widget.on_icon : widget.off_icon),
      onPressed: widget.onChanged == null
          ? null
          : () {
              setState(() {
                _isOn = !_isOn;
                if (widget.onChanged != null) widget.onChanged!(_isOn);
              });
            },
    );
  }
}
