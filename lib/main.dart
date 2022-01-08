import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:meditate_audio_players/audio_asset_player.dart';
// android/buildgradle change to => ext.kotlin_version = '1.4.21'
// audioplayers: ^0.20.1 package
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const iconSize = 50.0;
  final player = AudioAssetPlayer("song.mp3");

  late final StreamSubscription progressSubscription;
  late final StreamSubscription stateSubscription;

  double progress = 0.0;
  PlayerState state = PlayerState.STOPPED;

  late final Future initFuture;

  @override
  void initState() {
    initFuture = player.init().then((value) {
      progressSubscription =
          player.progressStream.listen((p) => setState(() => progress = p));

      stateSubscription =
          player.stateStream.listen((s) => setState(() => state = s));
    });
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Player"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: FutureBuilder<void>(
            future: initFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Text("Loading");
              }
              return Card(
                elevation: 3.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.filename,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildPlayButton(),
                        buildPauseButton(),
                        buildStopButton(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(
                        32.0,
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildPlayButton() {
    if (state == PlayerState.PLAYING) {
      return const IconButton(
        onPressed: null,
        icon: Icon(
          Icons.play_arrow,
          color: Colors.grey,
          size: iconSize,
        ),
      );
    }
    return IconButton(
        onPressed: player.play,
        icon: const Icon(
          Icons.play_arrow,
          color: Colors.green,
          size: iconSize,
        ));
  }

  Widget buildPauseButton() {
    if (state != PlayerState.PLAYING) {
      return const IconButton(
        onPressed: null,
        icon: Icon(
          Icons.pause,
          color: Colors.grey,
          size: iconSize,
        ),
      );
    }
    return IconButton(
      onPressed: player.pause,
      icon: const Icon(
        Icons.pause,
        color: Colors.orange,
        size: iconSize,
      ),
    );
  }

  Widget buildStopButton() {
    if (state == PlayerState.STOPPED) {
      return const IconButton(
        onPressed: null,
        icon: Icon(
          Icons.stop,
          color: Colors.grey,
          size: iconSize,
        ),
      );
    }
    return IconButton(
      onPressed: player.reset,
      icon: const Icon(
        Icons.stop,
        color: Colors.red,
        size: iconSize,
      ),
    );
  }
}
