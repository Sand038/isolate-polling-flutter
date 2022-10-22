import 'dart:async';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:flutter/material.dart';
import 'package:pausable_timer/pausable_timer.dart';

void main() {
  runApp(const MyApp());
}

late PausableTimer _timer;
int _counter = 0;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

void mainHandler(dynamic data, SendPort isolateSendPort) {}

void isolateHandler(
    dynamic data, SendPort mainSendPort, SendErrorFunction onSendError) {
  if (data == 'init') {
    _updateCount() {
      _counter++;
      print('Current counter value: $_counter');
    }

    void init() {
      _timer = PausableTimer(const Duration(seconds: 1), () {
        _timer
          ..reset()
          ..start();
        _updateCount();
      });
      _timer.start();
    }

    init();
  } else if (data == 'pause') {
    _timer.pause();
  } else if (data == 'resume') {
    _timer.start();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool flag = false;
  late Worker worker;

  _MyHomePageState();

  _startInitialPolling() async {
    print('Initial Polling Starting!!!');
    setState(() {
      flag = true;
    });
    worker = Worker();
    await worker.init(mainHandler, isolateHandler, initialMessage: 'init');
  }

  Future<void> _resumeAction() async {
    _startPolling();
  }

  Future<void> _pauseAction() async {
    _stopPolling();
  }

  void _startPolling() {
    worker.sendMessage('resume');
    print('Polling Resumed!!!');
  }

  void _stopPolling() {
    worker.sendMessage('pause');
    print('Polling Paused!!!');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: flag ? _pauseAction : null,
                    style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
                    child: const Text("Pause"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: flag ? null : _startInitialPolling,
                    style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
                    child: const Text("Start Polling"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: flag ? _resumeAction : null,
                    style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
                    child: const Text("Resume"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
