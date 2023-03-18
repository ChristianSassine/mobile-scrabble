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
  final _avatarService = GetIt.I.get<AvatarService>();
  late Future<dynamic> _images;

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
    _images = _avatarService.getDefaultAvatars();
  }

  void selectAvatar(int index, [String? imageURL]) {
    if (index >= 0 && imageURL!.isNotEmpty) {
      _selectAvatarFromList(File(imageURL), index);
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
                      FutureBuilder<dynamic>(
                        future: _images,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Expanded(
                                child: GestureDetector(
                              onTap: () => selectAvatar(
                                  i, snapshot.data!['default-spongebob'][0]),
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 3,
                                          color: _selectedImageIndex == i
                                              ? Colors.green
                                              : Colors.transparent)),
                                  child: Image.network(
                                    snapshot.data!['default-spongebob'][0],
                                    width: 50,
                                    height: 50,
                                  )),
                            ));
                          }
                          return const CircularProgressIndicator();
                        },
                      )
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
                    child: const Text('Prendre une photo')),
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

  @override
  void initState() {
    super.initState();
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
      return NetworkImage(_selectedImageFile!.path);
    } else {
      return FileImage(_selectedImageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openAvatarSelector(),
      mouseCursor: SystemMouseCursors.click,
      child: CircleAvatar(
          radius: 32.0,
          backgroundColor: Colors.black,
          child: CircleAvatar(
            radius: 30.0,
            backgroundImage: setAvatar(),
            backgroundColor:
                _selectedImageFile == null ? Colors.blue : Colors.transparent,
            child: _selectedImageFile == null
                ? const Icon(Icons.add, color: Colors.white, size: 30.0)
                : null,
          )),
    );
  }
}
