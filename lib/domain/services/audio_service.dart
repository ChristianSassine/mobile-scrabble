import 'package:audioplayers/audioplayers.dart';

const _notifPath = "audio/notification.mp3";

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioService() {
    _player.setSource(AssetSource(_notifPath));
    _player.onPlayerStateChanged.listen((state) {
      print(state);
      if (state == PlayerState.completed)
        _player.setSource(AssetSource(_notifPath));
    });
  }

  void playNotificationSound() async {
    _player.resume();
  }
}
