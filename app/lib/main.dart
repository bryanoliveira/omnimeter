import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';

import 'package:fl_chart/fl_chart.dart';

import 'charts/line.dart';
import 'charts/temp_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hardware Monitor',
      debugShowCheckedModeBanner: false,
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
  final limitCount = 100;
  bool offline = true;
  String offlineStatus = "";
  Map<String, dynamic> chartsData = Map<String, dynamic>();
  double currentX = 0;
  Timer? timer;
  int errorCount = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    fetchCpuData();
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
      body: Container(
        child: offline
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "OFFLINE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      offlineStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: chartsData.containsKey("cpu")
                            ? <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 25.0,
                                        bottom: 18,
                                      ),
                                      child: Text(
                                        "CPU " + chartsData["cpu"]["name"],
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 25.0,
                                        bottom: 18,
                                      ),
                                      child: Text(
                                        chartsData["cpu"]["frequency"]
                                                .toStringAsFixed(0) +
                                            " MHz",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 25.0,
                                        bottom: 18,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: chartsData["cpu"]
                                                ["coreUsageWidgets0"],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: chartsData["cpu"]
                                                ["coreUsageWidgets1"],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                CommonLineChart(
                                    data: chartsData["cpu"]["traces"],
                                    minY: chartsData["cpu"]["minY"],
                                    maxY: chartsData["cpu"]["maxY"]),
                              ]
                            : <Widget>[],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 50,
                            ),
                            child: TemperatureBarChart(
                              temperature: chartsData["cpu"]["temperature"],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: chartsData.containsKey("gpu")
                            ? <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 25.0,
                                        top: 24,
                                        bottom: 18,
                                      ),
                                      child: Text(
                                        "GPU " + chartsData["gpu"]["name"],
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 25.0,
                                        top: 24,
                                        bottom: 18,
                                      ),
                                      child: Text(
                                        chartsData["gpu"]["frequency"]
                                                .toStringAsFixed(0) +
                                            " MHz  |  " +
                                            chartsData["gpu"]["power"]
                                                .toStringAsFixed(0) +
                                            " W" +
                                            (chartsData["gpu"]["fps"] > 0
                                                ? "  |  " +
                                                    chartsData["gpu"]["fps"]
                                                        .toString() +
                                                    " FPS"
                                                : ""),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                CommonLineChart(
                                    data: chartsData["gpu"]["traces"],
                                    minY: chartsData["gpu"]["minY"],
                                    maxY: chartsData["gpu"]["maxY"]),
                              ]
                            : <Widget>[],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 70,
                            ),
                            child: TemperatureBarChart(
                              temperature: chartsData["gpu"]["temperature"],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void fetchCpuData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.12:5000'), headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD"
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) throw new Exception(response.statusCode);

      Wakelock.enable();
      offline = false;
      errorCount = 0;

      Map<String, dynamic> data = jsonDecode(response.body);

      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      setState(() {
        if (data.containsKey("default_cpu")) {
          setChartData("cpu", {
            "% Usage": data["default_cpu"]["utilization"],
            "% Memory": 100 *
                data["default_cpu"]["memory"]["current"] /
                data["default_cpu"]["memory"]["max"],
          }, {
            "name": data["default_cpu"]["name"],
            "temperature": data["default_cpu"]["temperature"],
            "frequency": data["default_cpu"]["frequency"]["current"],
          });
          // add two lines of core usage indicators
          chartsData["cpu"]["coreUsageWidgets0"] = <Widget>[];
          chartsData["cpu"]["coreUsageWidgets1"] = <Widget>[];
          for (int i = 0; i < data["default_cpu"]["core_usage"].length; i++) {
            var coreUsage = data["default_cpu"]["core_usage"][i];
            chartsData["cpu"]["coreUsageWidgets" + (i % 2).toString()].add(
              Padding(
                padding: EdgeInsets.only(
                  left: 5.0,
                  bottom: 5.0,
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: coreUsage < 20
                        ? Colors.grey[800]
                        : (coreUsage < 40
                            ? Colors.green[600]
                            : (coreUsage < 60
                                ? Colors.yellow[600]
                                : (coreUsage < 80
                                    ? Colors.orange[600]
                                    : Colors.red[600]))),
                  ),
                ),
              ),
            );
          }
        }

        if (data.containsKey("default_nvidia_gpu"))
          setChartData("gpu", {
            "% Usage": data["default_nvidia_gpu"]["0"]["utilization"],
            "% Memory": 100 *
                data["default_nvidia_gpu"]["0"]["memory"]["current"] /
                data["default_nvidia_gpu"]["0"]["memory"]["max"],
          }, {
            "name": data["default_nvidia_gpu"]["0"]["name"],
            "temperature": data["default_nvidia_gpu"]["0"]["temperature"],
            "fps": data["default_nvidia_gpu"]["0"]["fps"],
            "frequency": data["default_nvidia_gpu"]["0"]["frequency"]
                ["current"],
            "power": data["default_nvidia_gpu"]["0"]["power"]["current"],
          });

        currentX++;
      });
    } catch (e) {
      errorCount++;
      if (errorCount > 2) {
        setState(() {
          offline = true;
          offlineStatus = e.toString();
        });
        Wakelock.disable();
      }
    }
    // call this function again after some time
    Timer(Duration(seconds: 5), () {
      fetchCpuData();
    });
  }

  void setChartData(String key, Map<String, double> currentValues,
      Map<String, dynamic> immediateValues) {
    if (!chartsData.containsKey(key)) chartsData[key] = Map<String, dynamic>();

    immediateValues.forEach((title, value) {
      chartsData[key][title] = immediateValues[title];
    });

    chartsData[key]["minY"] =
        immediateValues.containsKey("minY") ? immediateValues["minY"] : 0.0;
    chartsData[key]["maxY"] =
        immediateValues.containsKey("maxY") ? immediateValues["maxY"] : 100.0;

    currentValues.forEach((title, value) {
      if (!chartsData[key].containsKey("traces"))
        chartsData[key]["traces"] = Map<String, dynamic>();
      if (!chartsData[key]["traces"].containsKey(title))
        chartsData[key]["traces"][title] = <FlSpot>[];

      while (chartsData[key]["traces"][title].length > limitCount) {
        chartsData[key]["traces"][title].removeAt(0);
      }

      chartsData[key]["traces"][title].add(FlSpot(currentX, value));
    });
  }
}
