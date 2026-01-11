import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart' as path;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Запись.Живо',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_text.isNotEmpty) {
      final file = await path.getApplicationDocumentsDirectory();
      final filePath = '${file.path}/${DateTime.now().millisecondsSinceEpoch}.txt';
      await File(filePath).writeAsString(_text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Запись.Живо')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : Colors.blue,
                padding: const EdgeInsets.all(20),
                shape: const CircleBorder(),
              ),
              child: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _text.isEmpty ? 'Говорите...' : _text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
