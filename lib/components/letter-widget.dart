import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/letter-enum.dart';

/// @brief Model for all letter (Visual widget)
class LetterWidget extends StatelessWidget {
  final String character;
  final int points;
  final double widgetSize;
  final double opacity;
  final Color? color;
  final Color _defaultColor = Colors.orange[200]!;

  LetterWidget(
      {super.key,
      required this.character,
      required this.points,
      required this.widgetSize,
      this.opacity = 1,
      this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widgetSize,
        width: widgetSize,
        child: Card(
          color: (color == null ? _defaultColor : color!).withOpacity(opacity),
          child: Stack(
            children: [
              Center(
                  child: Text(
                character != Letter.EMPTY.character ? character : "",
                style: TextStyle(fontSize: 0.4 * widgetSize, color: Colors.black),
              )),
              Positioned(
                bottom: widgetSize * 0.1,
                left: widgetSize * 0.55,
                child: Text(
                  points != 0 ? points.toString() : "",
                  style: TextStyle(
                    fontSize: 0.21 * widgetSize,
                    color: Colors.black
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class DraggedLetter extends StatelessWidget {
  const DraggedLetter({
    super.key,
    required this.value,
    required this.dragKey,
  });

  final GlobalKey dragKey;
  final Letter value;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
        translation: const Offset(0, -0.75),
        child: ClipRRect(
            key: dragKey,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 2.0, bottom: 0.0),
                child: LetterWidget(
                  character: value.character,
                  points: value.points,
                  widgetSize: 75,
                ))));
  }
}

class GhostLetter extends StatelessWidget {
  const GhostLetter({super.key, required this.value, required this.widgetSize});

  final Letter value;
  final double widgetSize;

  @override
  Widget build(BuildContext context) {
    return LetterWidget(
      character: value.character,
      points: value.points,
      widgetSize: widgetSize,
      opacity: 0.75,
    );
  }
}
