import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/domain/enums/image-type-enum.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';

const AVATAR_FROM_CAMERA = -1;

class AvatarSelectorDialog extends StatefulWidget {
  final Function(File, String, int) selectAvatarFromList;
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

  late final Function(File, String, int) _selectAvatarFromList;
  late final Function() _selectAvatarFromCamera;

  @override
  void initState() {
    super.initState();
    _selectAvatarFromList = widget.selectAvatarFromList;
    _selectAvatarFromCamera = widget.selectAvatarFromCamera;
    _selectedImageIndex = widget.selectedImageIndex;
    _images = _avatarService.getDefaultAvatars();
  }

  void selectAvatar(int index, [String? imageURL, String? name]) {
    if (index >= 0 && imageURL!.isNotEmpty) {
      _selectAvatarFromList(File(imageURL), name!, index);
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
                FutureBuilder<dynamic>(
                  future: _images,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Placeholder(); // TODO: Handle error
                      }
                      if (snapshot.hasData) {
                        List<Widget> widgets = [];
                        for (int i = 0; i < snapshot.data.length; i++) {
                          widgets.add(Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    selectAvatar(
                                        i,
                                        snapshot.data![snapshot.data.keys
                                            .elementAt(i)]
                                        [0], snapshot.data.keys
                                        .elementAt(i)),
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 3,
                                            color: _selectedImageIndex == i
                                                ? Colors.green
                                                : Colors.transparent)),
                                    child: Image.network(
                                      snapshot.data![snapshot.data.keys
                                          .elementAt(i)]
                                      [0],
                                      width: 50,
                                      height: 50,
                                    )),
                              )));
                        }
                        return Row(children: widgets);
                      }
                    }
                    return const CircularProgressIndicator();
                  },
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
  const AvatarSelector({Key? key, required this.onImageChange}) : super(key: key);
  final ValueChanged<AvatarData?> onImageChange;

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
      widget.onImageChange(AvatarData(ImageType.DataImage, file: _selectedImageFile));
    } catch (e) {
      print(e);
    }
  }

  void selectAvatarFromList(File selectedAvatar, String filename, int index) {
    setState(() {
      _selectedImageFile = selectedAvatar;
      _selectedImageIndex = index;
    });
    print("IN SELECT : ${filename}");
    widget.onImageChange(AvatarData(ImageType.UrlImage, name: filename, file: _selectedImageFile));
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
