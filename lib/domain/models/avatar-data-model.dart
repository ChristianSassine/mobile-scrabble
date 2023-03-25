import 'dart:io';

import 'package:mobile/domain/enums/image-type-enum.dart';

class AvatarData{
  String? name;
  ImageType type;
  String? url;
  File? file;

  AvatarData(this.type, {this.name, this.url, this.file});

  AvatarData.fromJson(json)
      : name = json['name'],
        type = ImageType.fromString(json['type']),
        url = json['url'],
        file = json['file'];

  Map toJson() =>
      {"name": name,
        "type": type,
        "url": url,
        "file" : file
      };
}
