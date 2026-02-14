import 'package:speech_to_text/speech_to_text.dart';

/// Continuously listens for the phrase "help help" and fires [onHelpDetected].
class VoiceTriggerService {
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;

  /// Called when "help help" is detected in speech.
  Function? onHelpDetected;

  Future<void> start() async {
    final available = await _stt.initialize(
      onError: (error) => _onError(error),
      onStatus: (status) => _onStatus(status),
    );
    if (available) _listen();
  }

  void _listen() {
    if (_isListening) return;
    _isListening = true;

    _stt.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase();
        if (words.contains('help help')) {
          onHelpDetected?.call();
        }
      },
      // ✅ Fixed: use SpeechListenOptions instead of deprecated listenMode
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  void _onStatus(String status) {
    // Restart listening when it stops (keeps it always-on)
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      Future.delayed(const Duration(milliseconds: 500), _listen);
    }
  }

  void _onError(dynamic error) {
    _isListening = false;
    // Restart after error with a small delay
    Future.delayed(const Duration(seconds: 1), _listen);
  }

  void stop() {
    _isListening = false;
    _stt.stop();
  }
}
