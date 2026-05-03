import 'package:just_audio/just_audio.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccessSound() async {
    try {
      await _player.setAsset('assets/audio/success.mp3');
      await _player.play();
    } catch (e) {
      // if sound fails, don't crash the app — just continue silently
      print('Sound error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}