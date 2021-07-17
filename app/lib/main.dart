import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';

import 'package:fl_chart/fl_chart.dart';

import 'charts/line.dart';
import 'models/cpu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hardware Monitor',
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
        primaryColor: const Color(0xff262545),
        primaryColorDark: const Color(0xff201f39),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MyHomePage(title: 'Hardware Monitor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final cpuFreqs = <FlSpot>[];

  final limitCount = 100;
  Map<String, dynamic> chartsData = Map<String, dynamic>();
  double currentX = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer t) => fetchCpuData());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    timer?.cancel();
    super.dispose();
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: createCharts(),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void fetchCpuData() async {
    final response = await http.get(Uri.parse('http://192.168.0.4:5000'));
    if (response.statusCode == 200) {
      Wakelock.enable();

      Map<String, dynamic> data = jsonDecode(response.body);

      while (cpuFreqs.length > limitCount) {
        cpuFreqs.removeAt(0);
      }

      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      setState(() {
        setChartData(
          data["default_cpu"]["name"],
          data["default_cpu"]["utilization"],
        );

        setChartData(
          data["default_nvidia_gpu"]["0"]["name"],
          data["default_nvidia_gpu"]["0"]["utilization"],
        );

        currentX++;
      });
    } else {
      Wakelock.disable();
      throw Exception("Failed to load frequency");
    }
  }

  void setChartData(String key, double currentValue,
      [double? minY, double? maxY]) {
    if (!chartsData.containsKey(key)) chartsData[key] = Map<String, dynamic>();
    if (!chartsData[key].containsKey("data"))
      chartsData[key]["data"] = <FlSpot>[];

    while (chartsData[key]["data"].length > limitCount) {
      chartsData[key]["data"].removeAt(0);
    }
    chartsData[key]["minY"] = minY ?? 0.0;
    chartsData[key]["maxY"] = maxY ?? 100.0;
    chartsData[key]["data"].add(FlSpot(currentX, currentValue));
  }

  List<Widget> createCharts() {
    List<Widget> charts = <Widget>[];
    chartsData.forEach((key, chartData) => {
          if (chartData.containsKey("data"))
            charts.add(chartData["data"].isNotEmpty
                ? Container(
                    width: 300,
                    height: 100,
                    child: CommonLineChart(
                      data: chartData["data"],
                      minY: chartData["minY"],
                      maxY: chartData["maxY"],
                      title: key,
                    ),
                  )
                : Container())
        });

    return charts;
  }
}
