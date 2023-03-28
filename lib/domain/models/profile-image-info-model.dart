class ProfileImageInfo {
  String name;
  bool isDefaultPicture;
  String? key;

  ProfileImageInfo(this.name, this.isDefaultPicture, {this.key});

  ProfileImageInfo.fromJson(json)
      : name = json['name'],
        isDefaultPicture = json['isDefaultPicture'],
        key = json['key'];

  Map toJson() =>
      {"name": name,
        "isDefaultPicture": isDefaultPicture,
        "key": key,
      };
}
