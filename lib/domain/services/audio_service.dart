import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

const _notifPath = "audio/notification.mp3";

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioService() {
    _player.setSource(AssetSource(_notifPath));
    _player.onPlayerStateChanged.listen((state) {
      debugPrint("AudioPlayer : $state");
      if (state == PlayerState.completed) {
        _player.setSource(AssetSource(_notifPath));
      }
    });
  }

  void playNotificationSound() async {
    _player.resume();
  }
}
