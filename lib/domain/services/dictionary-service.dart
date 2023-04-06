import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/dictionary-model.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';

class DictionaryService {
  final _httpService = GetIt.I.get<HttpHandlerService>();

  Subject<bool> notifyNewDictionaries = PublishSubject();

  List<DictionaryInfo> dictionaries = [];

  DictionaryService() {
    fetchDictionaries();
  }

  Future<void> fetchDictionaries() async {
    try {
      var response = await _httpService.fetchDictionaries();
      if (response.statusCode == HttpStatus.ok) {
        dictionaries = jsonDecode(response.body)
            .map<DictionaryInfo>((dictionaryData) => DictionaryInfo.fromJson(dictionaryData)).toList();
        notifyNewDictionaries.add(true);
      }
    } catch (_) {}
  }
}
