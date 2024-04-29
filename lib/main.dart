import 'dart:collection';
import 'dart:html';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final AudioPlayer _audioPlayer = AudioPlayer();
  String preVoices = '';
  String current = '';
  Queue<String> queue = Queue();

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.completed:
          print('completed');
          if(queue.isNotEmpty)
            playActionVoice(voiceId: queue.removeFirst(), versioning: true);
          break;
        default:
          break;
      }
    });
  }

  initQueue() {
    queue.clear();
    queue.addAll(List.of(['a','b','c','d']));
    setState(() {

    });
  }

  String versioningSource(String voiceId, bool versioning){
    if(!versioning) {
      preVoices = '';
      return voiceId;
    }
    if(preVoices.isEmpty){
      preVoices += "$voiceId,";
      return voiceId;
    }
    List<String> voices = preVoices.split(',');
    int dupl = voices.where((pre) => pre == voiceId).toList().length;
    preVoices += "$voiceId,";
    if(dupl != 0) return voiceId + dupl.toString();
    return voiceId;
  }

  UrlSource mp3UrlFromVoiceId(String voiceId, bool versioning) {
    String id = versioningSource(voiceId, versioning);
    print("playActionVoice//// : $id");
    Uri uri = Uri.parse(window.location.href);
    String mp3Url = '${uri.scheme}://${uri.host}:${uri.port}/mp3';
    return UrlSource('$mp3Url/$id.mp3');
  }

  void playActionVoice({required String voiceId, required bool versioning}) {
    setState(() {});
    _audioPlayer.stop();
    // _audioPlayer.audioCache.clearAll();
    // Future.delayed(Duration(milliseconds: 700), () {
    _audioPlayer.play(mp3UrlFromVoiceId(voiceId, versioning), position: Duration(milliseconds: 0));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'voices',
            ),
            Text(
              'queue: ${queue.toString()}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
        {
          initQueue(),
          Future.delayed(Duration(milliseconds: 1000), () => playActionVoice(voiceId: queue.removeFirst(), versioning: true)),
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}