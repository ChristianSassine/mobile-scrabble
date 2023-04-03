import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/domain/enums/image-type-enum.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/userimageinfo-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';

class AvatarSelectorDialog extends StatefulWidget {
  final Function(File, String) selectAvatarFromList;
  final Function() selectAvatarFromCamera;

  const AvatarSelectorDialog({
    super.key,
    required this.selectAvatarFromList,
    required this.selectAvatarFromCamera,
    this.selectedName,
  });

  final selectedName;

  @override
  _AvatarSelectorDialogState createState() => _AvatarSelectorDialogState();
}

class _AvatarSelectorDialogState extends State<AvatarSelectorDialog> {
  final _avatarService = GetIt.I.get<AvatarService>();
  late Future<dynamic> _images;

  String? _selectedImageName;

  late final Function(File, String) _selectAvatarFromList;
  late final Function() _selectAvatarFromCamera;

  @override
  void initState() {
    super.initState();
    _selectAvatarFromList = widget.selectAvatarFromList;
    _selectAvatarFromCamera = widget.selectAvatarFromCamera;
    _selectedImageName = widget.selectedName;
    _images = _avatarService.getDefaultAvatars();
  }

  void selectAvatar([String? imageURL, String? name]) {
    if (imageURL != null && imageURL.isNotEmpty) {
      _selectAvatarFromList(File(imageURL), name!);
      _selectedImageName = name;
    } else {
      _selectAvatarFromCamera();
      Navigator.pop(context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              FlutterI18n.translate(context, "avatar.close"),
            ),
          ),
        ],
        title: Text(FlutterI18n.translate(context, "avatar.title")),
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
                        return Text(
                          FlutterI18n.translate(context, 'avatar.error'),
                          style: TextStyle(color: Theme.of(context).errorColor),
                        );
                      }
                      if (snapshot.hasData) {
                        List<Widget> widgets = [];
                        for (int i = 0; i < snapshot.data.length; i++) {
                          widgets.add(GestureDetector(
                            onTap: () => selectAvatar(
                            snapshot.data![snapshot.data.keys.elementAt(i)]
                                [0],
                            snapshot.data.keys.elementAt(i)),
                            child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3,
                                    color: _selectedImageName ==
                                            snapshot.data.keys.elementAt(i)
                                        ? Colors.green
                                        : Colors.transparent)),
                            child: Image.network(
                              snapshot.data![
                                  snapshot.data.keys.elementAt(i)][0],
                              width: 75,
                              height: 75,
                            )),
                          ));
                        }
                        return Center(
                          child: Container(
                            width: size.width * 0.40,
                              child: Wrap(children: widgets)),
                        );
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
                    onPressed: () => selectAvatar(),
                    child: Text(
                        FlutterI18n.translate(context, "avatar.take_image"))),
              ],
            )));
  }
}

class AvatarSelector extends StatefulWidget {
  const AvatarSelector(
      {Key? key, required this.onImageChange, this.currentInfo})
      : super(key: key);

  final ValueChanged<AvatarData?> onImageChange;
  final UserImageInfo? currentInfo;

  @override
  _AvatarSelectorState createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  File? _selectedImageFile;
  String? _imageName;
  bool _isImageUrl = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentInfo != null) {
      // TODO: TO TEST
      _selectedImageFile = File(widget.currentInfo!.key!);
      if (widget.currentInfo!.isDefaultPicture) {
        _imageName = widget.currentInfo!.name;
      }
      _isImageUrl = true;
    }
  }

  Future selectAvatarFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      setState(() {
        _selectedImageFile = File(image.path);
        _imageName = null;
        _isImageUrl = false;
      });
      widget.onImageChange(
        AvatarData(ImageType.DataImage, file: _selectedImageFile),
      );
    } catch (e) {
      print(e);
    }
  }

  void selectAvatarFromList(File selectedAvatar, String filename) {
    setState(() {
      _selectedImageFile = selectedAvatar;
      _imageName = filename;
      _isImageUrl = true;
    });
    widget.onImageChange(AvatarData(ImageType.UrlImage,
        name: filename, file: _selectedImageFile));
  }

  Future openAvatarSelector() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => AvatarSelectorDialog(
              selectAvatarFromList: selectAvatarFromList,
              selectAvatarFromCamera: selectAvatarFromCamera,
              selectedName: _imageName,
            ));
  }

  setAvatar() {
    if (_selectedImageFile == null) {
      return null;
    } else if (_selectedImageFile != null && _isImageUrl) {
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
