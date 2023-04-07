class UserImageInfo {
  String? name;
  bool isDefaultPicture;
  String? key;

  UserImageInfo(this.name, this.isDefaultPicture, {this.key});

  UserImageInfo.fromJson(json)
      : name = json['name'],
        isDefaultPicture = json['isDefaultPicture'],
        key = json['key'];

  Map toJson() =>
      {"name": name, "isDefaultPicture": isDefaultPicture, "key": key};
}
