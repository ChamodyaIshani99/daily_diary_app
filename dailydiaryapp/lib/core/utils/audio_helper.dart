import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';

class AudioHelper {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool isRecording = false;
  bool isPlaying = false;

  // 1. Start voice recording
  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = path.join(appDocDir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      isRecording = true;
    }
  }

  // 2. Stop voice recording and get the file path
  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    isRecording = false;
    return path;
  }

  // 3. Play audio
  Future<void> playAudio(String filePath, Function onComplete) async {
    if (File(filePath).existsSync()) {
      await _audioPlayer.play(DeviceFileSource(filePath));
      isPlaying = true;

      _audioPlayer.onPlayerComplete.listen((event) {
        isPlaying = false;
        onComplete();
      });
    }
  }

  // 4. Stop audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying = false;
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}