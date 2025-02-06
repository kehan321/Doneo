import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late SpeechToText _speechToText;
  String _text = "Press the button to start speaking";

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _speechToText.listen(onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speech to Text')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text, style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: _startListening,
              child: Text('Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
