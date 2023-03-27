import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/letter-enum.dart';

/// @brief Model for all letter (Visual widget)
class LetterWidget extends StatelessWidget {
  final String character;
  final int points;
  final double widgetSize;
  final double opacity;
  final bool highlighted;

  const LetterWidget(
      {super.key,
      required this.character,
      required this.points,
      required this.widgetSize,
      this.opacity = 1,
      this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widgetSize,
        width: widgetSize,
        child: Card(
          color: Colors.orange[highlighted ? 100 : 200]!.withOpacity(opacity),
          child: Stack(
            children: [
              Center(
                  child: Text(
                character != Letter.EMPTY.character ? character : "",
                style: TextStyle(fontSize: 0.4 * widgetSize, color: Colors.black),
              )),
              Positioned(
                bottom: widgetSize * 0.1,
                right: widgetSize * 0.08,
                child: Text(
                  points != 0 ? points.toString() : "",
                  style: TextStyle(
                    fontSize: 0.3 * widgetSize,
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
  GhostLetter({super.key, required this.value, required this.widgetSize});

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
