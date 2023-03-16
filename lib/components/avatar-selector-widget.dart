import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

class AvatarSelectorDialog extends StatefulWidget {
  final Function(File, int) selectedAvatar;
  int? selectedImageIndex;

  AvatarSelectorDialog(
      {required this.selectedAvatar, required this.selectedImageIndex});

  @override
  _AvatarSelectorDialogState createState() => _AvatarSelectorDialogState();
}

class _AvatarSelectorDialogState extends State<AvatarSelectorDialog> {
  int? _selectedImageIndex;
  final List<String> _defaultImages = [
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/scrabble_logo.png',
  ];
  late final Function(File, int) _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.selectedAvatar;
    _selectedImageIndex = widget.selectedImageIndex;
  }

  void selectedAvatar(int index) {
    _selectedAvatar(File(_defaultImages[index]), index);
    setState(() {
      _selectedImageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Choisir');
            },
            child: Text('Choisir'),
          ),
        ],
        title: const Text('Choisis ton avatar'),
        content: Center(
            heightFactor: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < _defaultImages.length; i++)
                      Expanded(
                          child: GestureDetector(
                        onTap: () => selectedAvatar(i),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 3,
                                  color: _selectedImageIndex == i
                                      ? Colors.green
                                      : Colors.transparent)),
                          child: Image.asset(
                            _defaultImages[i],
                            width: 50,
                            height: 50,
                          ),
                        ),
                      )),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                ),
                Row(children: const <Widget>[
                  Expanded(child: Divider()),
                  Text("OU"),
                  Expanded(child: Divider()),
                ]),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                ),
                ElevatedButton(
                    onPressed: () => print('hi'),
                    child: Text('Prendre une photo'))
              ],
            )));
  }
}

class AvatarSelector extends StatefulWidget {
  AvatarSelector({Key? key}) : super(key: key);

  @override
  _AvatarSelectorState createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  File? _selectedImageFile;
  int? _selectedImageIndex;
  // final picker = ImagePicker();
  // final List<String> _defaultImages = [
  //   'assets/images/test.png',
  //   'assets/images/test.png',
  //   'assets/images/test.png',
  // ];

  // Future selectAvatar() async {
  //   try {
  //     final image = await picker.pickImage(source: ImageSource.camera);
  //     if (image == null) return;
  //     setState(() {
  //       _selectedImageFile = File(image.path);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  void selectedAvatar(File selectedAvatar, int index) {
    print('here');
    setState(() {
      _selectedImageFile = selectedAvatar;
      _selectedImageIndex = index;
    });
  }

  Future openAvatarSelector() => showDialog(
      context: context,
      builder: (BuildContext context) => AvatarSelectorDialog(
            selectedAvatar: selectedAvatar,
            selectedImageIndex: _selectedImageIndex,
          ));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openAvatarSelector(),
      child: CircleAvatar(
        radius: 30.0,
        backgroundImage: _selectedImageFile != null
            ? AssetImage(_selectedImageFile!.path)
            : null,
        child: _selectedImageFile == null
            ? const Icon(Icons.add, color: Colors.white, size: 30.0)
            : null,
      ),
    );
  }
}
