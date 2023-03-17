import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/domain/services/avatar-service.dart';

const AVATAR_FROM_CAMERA = -1;

class AvatarSelectorDialog extends StatefulWidget {
  final Function(File, int) selectAvatarFromList;
  final Function() selectAvatarFromCamera;
  int? selectedImageIndex;

  AvatarSelectorDialog({
    super.key,
    required this.selectAvatarFromList,
    required this.selectAvatarFromCamera,
    this.selectedImageIndex,
  });

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
  late final Function(File, int) _selectAvatarFromList;
  late final Function() _selectAvatarFromCamera;

  @override
  void initState() {
    super.initState();
    _selectAvatarFromList = widget.selectAvatarFromList;
    _selectAvatarFromCamera = widget.selectAvatarFromCamera;
    _selectedImageIndex = widget.selectedImageIndex;
  }

  void selectAvatar(int index) {
    if (index >= 0) {
      _selectAvatarFromList(File(_defaultImages[index]), index);
    } else {
      _selectAvatarFromCamera();
      Navigator.pop(context, 'Choisir');
    }
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
            child: const Text(
              'Choisir',
              // style: TextStyle(
              //   color: Colors.black,
              // ),
            ),
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
                        onTap: () => selectAvatar(i),
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
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                Row(children: const <Widget>[
                  Expanded(child: Divider()),
                  Text("OU"),
                  Expanded(child: Divider()),
                ]),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                ElevatedButton(
                    onPressed: () => selectAvatar(AVATAR_FROM_CAMERA),
                    child: const Text('Prendre une photo'))
              ],
            )));
  }
}

class AvatarSelector extends StatefulWidget {
  const AvatarSelector({Key? key}) : super(key: key);

  @override
  _AvatarSelectorState createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  File? _selectedImageFile;
  int? _selectedImageIndex;
  final _avatarService = GetIt.I.get<AvatarService>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      // Call your async function here
      await getDefaultAvatar();
    });
  }

  Future selectAvatarFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      setState(() {
        _selectedImageFile = File(image.path);
        _selectedImageIndex = AVATAR_FROM_CAMERA;
      });
    } catch (e) {
      print(e);
    }
  }

  void selectAvatarFromList(File selectedAvatar, int index) {
    setState(() {
      _selectedImageFile = selectedAvatar;
      _selectedImageIndex = index;
    });
  }

  Future openAvatarSelector() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => AvatarSelectorDialog(
              selectAvatarFromList: selectAvatarFromList,
              selectAvatarFromCamera: selectAvatarFromCamera,
              selectedImageIndex: _selectedImageIndex,
            ));
  }

  setAvatar() {
    if (_selectedImageFile == null) {
      return null;
    } else if (_selectedImageFile != null &&
        _selectedImageIndex! != AVATAR_FROM_CAMERA) {
      return AssetImage(_selectedImageFile!.path);
    } else {
      return FileImage(_selectedImageFile!);
    }
  }

  getDefaultAvatar() async {
    await _avatarService.defaultAvatars();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openAvatarSelector(),
      child: CircleAvatar(
        radius: 30.0,
        backgroundImage: setAvatar(),
        child: _selectedImageFile == null
            ? const Icon(Icons.add, color: Colors.white, size: 30.0)
            : null,
      ),
    );
  }
}
