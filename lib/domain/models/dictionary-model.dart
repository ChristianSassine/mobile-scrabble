class DictionaryInfo {
  String title;
  String description;

  DictionaryInfo.fromJson(data)
      : title = data['title'],
        description = data['description'];
}
