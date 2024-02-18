import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _inputText = '';
  String _translatedText = '';
  String _targetLanguage = 'en';
  String _detectedLanguage = '';
  List<dynamic> _availaibleLangauges = ['en', 'fr'];

  static const _headers = {
    'content-type': 'application/x-www-form-urlencoded',
    'X-RapidAPI-Key': 'b86611b0fdmsh0cc804dcb662c70p1c6b8bjsn4824cc4241d5',
    'X-RapidAPI-Host': 'google-translate113.p.rapidapi.com'
  };

  static const api_uri = 'https://google-translate113.p.rapidapi.com/api/v1/translator/detect-language';

  Future<void> _getAvailaibleLanguages() async {
    final response = await http.get(
      Uri.parse('https://google-translate113.p.rapidapi.com/api/v1/translator/support-languages'), 
      headers: {
    'X-RapidAPI-Key': 'b86611b0fdmsh0cc804dcb662c70p1c6b8bjsn4824cc4241d5',
    'X-RapidAPI-Host': 'google-translate113.p.rapidapi.com'
   }
    );

     if (response.statusCode == 200) {
      setState(() {
        _availaibleLangauges = jsonDecode(response.body).map((item) => item['code']).toList();
      });
    } else {
      print(response.body);
      throw Exception('Failed to load');
    }
  }


  Future<void> _detectText() async {
    final response = await http.post(
      Uri.parse(api_uri),
      headers : _headers,
      body: {
        'text': _inputText,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _detectedLanguage = jsonDecode(response.body)['source_lang_code'];
        print(jsonDecode(response.body)['source_lang_code']);
      });
    } else {
      print(response.body);
      throw Exception('Failed to load');
    }
  }

  Future<void> _translateText() async {
    final response = await http.post(
      Uri.parse('https://google-translate113.p.rapidapi.com/api/v1/translator/text'),
      headers : _headers,
      body: {
        'from': _detectedLanguage,
        'to': _targetLanguage,
        'text': _inputText
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _translatedText = jsonDecode(response.body)['trans'];
      });
    } else {
      print(response.body);
      throw Exception('Failed to load');
    }
  }

  @override
  void initState() {
    super.initState();
    _getAvailaibleLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translation App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _targetLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _targetLanguage = newValue ?? '';
                });
              },
              items: _availaibleLangauges
                  .map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _detectText,
              child: Text('Detect'),
            ),
            ElevatedButton(
              onPressed: _translateText,
              child: Text('Translate'),
            ),
            Text(_detectedLanguage),
            Text(_translatedText),
          ],
        ),
      ),
    );
  }
}
