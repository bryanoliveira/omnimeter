import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'charts/line.dart';
import 'charts/temp_bar.dart';
import 'charts/pie.dart';
import 'charts/icon_legend_vertical.dart';

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
  String serverIp = '10.0.0.2';
  String serverPort = '5000';
  TextEditingController _ipTextFieldController = TextEditingController();
  TextEditingController _portTextFieldController = TextEditingController();

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    loadServerConfig();
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _displayTextInputDialog(context);
        },
        behavior: HitTestBehavior.opaque,
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
            : Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 20,
                  bottom: 15,
                ),
                child: Row(
                  // Charts / Icons
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Charts
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // CPU
                        Row(
                          children: [
                            // Single Column
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "CPU " + chartsData["cpu"]["name"],
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 25.0,
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
                                          left: 75.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: chartsData["cpu"]
                                                  ["coreUsageWidgets0"],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: chartsData["cpu"]
                                                  ["coreUsageWidgets1"],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  // Charts
                                  children: [
                                    Column(children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          right: 18,
                                        ),
                                        child: TemperatureBarChart(
                                          temperature: chartsData["cpu"]
                                              ["temperature"],
                                        ),
                                      ),
                                    ]),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: chartsData.containsKey("cpu")
                                          ? <Widget>[
                                              CommonLineChart(
                                                data: chartsData["cpu"]
                                                    ["traces"],
                                                minY: chartsData["cpu"]["minY"],
                                                maxY: chartsData["cpu"]["maxY"],
                                              )
                                            ]
                                          : <Widget>[],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          // GPU
                          children: [
                            // single column
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    bottom: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "GPU " + chartsData["gpu"]["name"],
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 25.0,
                                        ),
                                        child: Text(
                                          chartsData["gpu"]["frequency"]
                                                  .toStringAsFixed(0) +
                                              " MHz  |  " +
                                              chartsData["gpu"]["power"]
                                                  .toStringAsFixed(0) +
                                              " W",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 5,
                                            right: 18,
                                          ),
                                          child: TemperatureBarChart(
                                            temperature: chartsData["gpu"]
                                                ["temperature"],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: chartsData.containsKey("gpu")
                                          ? <Widget>[
                                              CommonLineChart(
                                                  data: chartsData["gpu"]
                                                      ["traces"],
                                                  minY: chartsData["gpu"]
                                                      ["minY"],
                                                  maxY: chartsData["gpu"]
                                                      ["maxY"]),
                                            ]
                                          : <Widget>[],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        // Top Icons
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  direction: Axis.vertical,
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.spaceEvenly,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: chartsData["cpu"]
                                          ["diskUsageWidgets"] +
                                      chartsData["bluetoothWidgets"],
                                )
                              ],
                            ),
                          ),
                          // Bottom Icons
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Wrap(
                                  direction: Axis.vertical,
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.spaceEvenly,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: (chartsData
                                              .containsKey("connections")
                                          ? (chartsData["connections"]
                                                          ["total"] >
                                                      0
                                                  ? <StatelessWidget>[
                                                      IconLegendVertical(
                                                        icon: Icons.link,
                                                        text: chartsData[
                                                                    "connections"]
                                                                ["total"]
                                                            .toString(),
                                                      )
                                                    ]
                                                  : <StatelessWidget>[]) +
                                              (chartsData["connections"]
                                                          ["users"] >
                                                      1
                                                  ? <StatelessWidget>[
                                                      IconLegendVertical(
                                                        icon: Icons
                                                            .supervisor_account,
                                                        text: chartsData[
                                                                    "connections"]
                                                                ["users"]
                                                            .toString(),
                                                      ),
                                                    ]
                                                  : [])
                                          : <StatelessWidget>[]) +
                                      [
                                        // Standing Desk Time
                                        chartsData["standingDesk"]
                                                    ["total_string"] !=
                                                null
                                            ? IconLegendVertical(
                                                icon: Icons.accessibility_new,
                                                text: chartsData["standingDesk"]
                                                    ["total_string"],
                                                iconColor:
                                                    chartsData["standingDesk"]
                                                                ["last_on"] ==
                                                            true
                                                        ? Colors.white
                                                        : Color.fromARGB(
                                                            255, 49, 48, 48))
                                            : Container(),

                                        // Total time
                                        chartsData["display"]["total_string"] !=
                                                null
                                            ? IconLegendVertical(
                                                icon: Icons.monitor,
                                                text: chartsData["display"]
                                                    ["total_string"])
                                            : Container(),

                                        // Connections
                                      ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> saveServerConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverIp', serverIp);
    await prefs.setString('serverPort', serverPort);
  }

  Future<void> loadServerConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serverIp = prefs.getString('serverIp') ?? '10.0.0.2';
      serverPort = prefs.getString('serverPort') ?? '5000';
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    _ipTextFieldController.text = serverIp;
    _portTextFieldController.text = serverPort;

    var wifiIP = await NetworkInfo().getWifiIP();
    if (wifiIP == null) return;
    var subnet = ipToCSubnet(wifiIP);

    final scanner = LanScanner();
    final List<Host> hosts = [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Start scanning asynchronously
            Future<void> scanNetwork() async {
              for (int i = 2; i <= 255; i += 5) {
                final int endIP = (i + 4 <= 255) ? i + 4 : 255;
                final List<Host> partialHosts = await scanner.quickIcmpScanSync(
                  subnet,
                  firstIP: i,
                  lastIP: endIP,
                );

                if (partialHosts.isEmpty) return;

                try {
                  setModalState(() {
                    hosts.addAll(partialHosts);
                  });
                } catch (e) {
                  return;
                }
              }
            }

            // Start the scan
            scanNetwork();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setModalState(() {
                              serverIp = value;
                              saveServerConfig();
                            });
                          },
                          controller: _ipTextFieldController,
                          decoration:
                              InputDecoration(hintText: 'Enter Server IP'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setModalState(() {
                              serverPort = value;
                              saveServerConfig();
                            });
                          },
                          controller: _portTextFieldController,
                          decoration:
                              InputDecoration(hintText: 'Port (e.g. 5000)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: hosts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text('${hosts[index].internetAddress.address}'),
                          onTap: () {
                            setState(() {
                              serverIp =
                                  '${hosts[index].internetAddress.address}';
                              _ipTextFieldController.text = serverIp;

                              saveServerConfig();
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void fetchCpuData() async {
    try {
      final response = await http
          .get(Uri.parse("http://" + serverIp + ":" + serverPort), headers: {
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
            "% Swap": 100 *
                data["default_cpu"]["swap"]["current"] /
                data["default_cpu"]["swap"]["max"],
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
        chartsData["cpu"]["diskUsageWidgets"] = <Widget>[];
        data["default_cpu"]["disks"].forEach((disk, usage) {
          chartsData["cpu"]["diskUsageWidgets"].add(
            DiskPieChart(
              percentage: usage,
            ),
          );
        });

        if (data.containsKey("default_nvidia_gpu"))
          setChartData("gpu", {
            "% Usage": data["default_nvidia_gpu"]["0"]["utilization"],
            "% Memory": 100 *
                data["default_nvidia_gpu"]["0"]["memory"]["current"] /
                data["default_nvidia_gpu"]["0"]["memory"]["max"],
            "% Power": 100 *
                data["default_nvidia_gpu"]["0"]["power"]["current"] /
                data["default_nvidia_gpu"]["0"]["power"]["max"],
          }, {
            "name": data["default_nvidia_gpu"]["0"]["name"],
            "temperature": data["default_nvidia_gpu"]["0"]["temperature"],
            "frequency": data["default_nvidia_gpu"]["0"]["frequency"]
                ["current"],
            "power": data["default_nvidia_gpu"]["0"]["power"]["current"],
          });

        if (data.containsKey("default_display")) {
          // check if data wasn't initialized or it was last updated yesterday
          if (!chartsData.containsKey("display") ||
              chartsData["display"]["last_updated"].day != DateTime.now().day) {
            chartsData["display"] = Map<String, dynamic>();
            chartsData["display"]["total_time_ms"] = 0;
            chartsData["display"]["last_updated"] = DateTime.now();
            chartsData["display"]["last_on"] =
                data["default_display"]["status"] == "on";
          }

          // sum the difference between now and the last updated time
          if (chartsData["display"]["last_on"] &&
              data["default_display"]["status"] == "on")
            chartsData["display"]["total_time_ms"] += DateTime.now()
                .difference(chartsData["display"]["last_updated"])
                .inMilliseconds;

          chartsData["display"]["last_updated"] = DateTime.now();
          chartsData["display"]["last_on"] =
              data["default_display"]["status"] == "on";

          if (chartsData["display"].containsKey("total_time_ms"))
            chartsData["display"]["total_string"] = ((chartsData["display"]
                            ["total_time_ms"] >
                        3600000
                    ? Duration(
                                milliseconds: chartsData["display"]
                                    ["total_time_ms"])
                            .inHours
                            .toString() +
                        "h"
                    : "") +
                (Duration(milliseconds: chartsData["display"]["total_time_ms"])
                            .inMinutes %
                        60)
                    .toString() +
                "m");
        }

        if (data.containsKey("standing_desk")) {
          // check if data wasn't initialized or it was last updated yesterday
          if (!chartsData.containsKey("standingDesk") ||
              chartsData["standingDesk"]["last_updated"].day !=
                  DateTime.now().day) {
            chartsData["standingDesk"] = Map<String, dynamic>();
            chartsData["standingDesk"]["total_time_ms"] = 0;
            chartsData["standingDesk"]["last_updated"] = DateTime.now();
            chartsData["standingDesk"]["last_on"] =
                data["standing_desk"]["standing"];
          }

          // sum the difference between now and the last updated time
          if (chartsData["standingDesk"]["last_on"] &&
              data["standing_desk"]["standing"] &&
              data["default_display"]["status"] == "on")
            chartsData["standingDesk"]["total_time_ms"] += DateTime.now()
                .difference(chartsData["standingDesk"]["last_updated"])
                .inMilliseconds;

          chartsData["standingDesk"]["last_updated"] = DateTime.now();
          chartsData["standingDesk"]["last_on"] =
              data["standing_desk"]["standing"];

          if (chartsData["standingDesk"].containsKey("total_time_ms"))
            chartsData["standingDesk"]["total_string"] =
                ((chartsData["standingDesk"]["total_time_ms"] > 3600000
                        ? Duration(
                                    milliseconds: chartsData["standingDesk"]
                                        ["total_time_ms"])
                                .inHours
                                .toString() +
                            "h"
                        : "") +
                    (Duration(
                                    milliseconds: chartsData["standingDesk"]
                                        ["total_time_ms"])
                                .inMinutes %
                            60)
                        .toString() +
                    "m");
        }

        if (data.containsKey("default_connections")) {
          chartsData["connections"] = Map<String, dynamic>();
          chartsData["connections"]["total"] =
              data["default_connections"]["total"];
          chartsData["connections"]["users"] =
              data["default_connections"]["users"];
        }

        chartsData["bluetoothWidgets"] = <Widget>[
          SizedBox(height: 5),
        ];
        const icon_map = {
          "input-keyboard": Icons.keyboard,
          "audio-headset": Icons.headset_mic,
          "input-gaming": Icons.gamepad,
        };
        data["bluetooth"]["devices"].forEach((device) {
          var icon = icon_map[device["icon"]];
          if (icon == null) icon = Icons.bluetooth;
          if (device.containsKey("battery")) {
            chartsData["bluetoothWidgets"]
                .add(IconLegendVertical(text: device["battery"], icon: icon));
          }
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
