import 'package:flutter/material.dart';
import 'package:mobile/domain/models/board-models.dart';

/// @brief Model for all letter (Visual widget)
class LetterWidget extends StatelessWidget {
  final String value;

  const LetterWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 6.0, right: 6.0, top: 2.0, bottom: 0.0),
      child: SizedBox(
      height: 75,
      width: 75,
      child: Card(
        color: Colors.orangeAccent[100],
        child: Center(
            child: Text(value,
              style: const TextStyle(fontSize: 30, color: Colors.black),)),
      ),
    ),);
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
        translation: const Offset(-0.5, -0.5),
        child: ClipRRect(
            key: dragKey,
            borderRadius: BorderRadius.circular(12.0),
            child: LetterWidget(value: value.value)));
  }
}

class DraggableLetter extends StatelessWidget {
  const DraggableLetter({
    super.key,
    required this.value,
    required this.dragKey,
  });

  final Letter value;
  final GlobalKey dragKey;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
        feedback: DraggedLetter(value: value, dragKey: dragKey),
        child: LetterWidget(value: value.value)
    );
  }
}
