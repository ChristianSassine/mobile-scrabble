import 'package:flutter/material.dart';
import 'package:mobile/domain/models/board-models.dart';

/// @brief Model for all letter (Visual widget)
class LetterWidget extends StatelessWidget {
  final String value;
  final double widgetSize;

  const LetterWidget(
      {super.key, required this.value, required this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widgetSize,
        width: widgetSize,
        child: Card(
          color: Colors.orangeAccent[100],
          child: Center(
              child: Text(
            value,
            style: TextStyle(fontSize: 0.4 * widgetSize, color: Colors.black),
          )),
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
        translation: const Offset(-0.1, -0.5),
        child: ClipRRect(
            key: dragKey,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 6.0, right: 6.0, top: 2.0, bottom: 0.0),
                child: LetterWidget(
                  value: value.value,
                  widgetSize: 75,
                ))));
  }
}

// class BoardLetter extends StatelessWidget {
//   const BoardLetter({
//     super.key,
//     required this.value,
//     required this.dragKey,
//   });
//
//   final GlobalKey dragKey;
//   final Letter value;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//         height: 30,
//         width: 30,
//         child: Card(
//           color: Colors.brown[200],
//           margin: EdgeInsets.zero,
//           shape: Border.all(color: Colors.white, width: 2),
//           child: Card(
//             color: Colors.orangeAccent[100],
//             child: Center(
//                 child: Text(
//                   value.value,
//                   style: TextStyle(fontSize: 0.4 * 30, color: Colors.black),
//                 )),
//           ),
//         ));
//   }
// }

class EaselLetter extends StatelessWidget {
  const EaselLetter(
      {super.key,
      required this.value,
      required this.dragKey,
      required this.widgetSize});

  final Letter value;
  final GlobalKey dragKey;
  final double widgetSize;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
        data: value,
        feedback: DraggedLetter(value: value, dragKey: dragKey),
        child: LetterWidget(value: value.value, widgetSize: 75));
  }
}
