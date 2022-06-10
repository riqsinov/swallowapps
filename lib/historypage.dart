import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/datamodel.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/loginpage.dart';
import 'package:swallow_monitoring/monitorpage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  int _selectedNavbar = 0;
  final db = FirebaseDatabase.instance.ref().child("DHT11/Data");
  late StreamSubscription _lastDataStream;

  String deviceId = '';

  void getDeviceId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('deviceId') != '')
      setState(() {
        deviceId = sharedPreferences.getString('device_Id')!;
      });
  }

  @override
  void initState() {
    getDeviceId();
    super.initState();
  }

  final _pageOptions = [
    HomePage(),
    DevicePage(),
    AddPage(),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(0), child: MonitorPage()),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(1), child: HistoryPage()),
  ];

  _onTap() {
    // this has changed
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => _pageOptions[_selectedNavbar]));
  }

  @override
  Widget build(BuildContext context) {
    final logoutButton = Material(
      elevation: 200,
      borderRadius: BorderRadius.circular(15),
      color: Colors.green,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () {
          logout(context);
        },
        child: Text(
          "Logout",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
    return Consumer<DataModel>(builder: (context, DataModel model, child) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedNavbar,
          backgroundColor: Colors.green,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("assets/Home.png"),
                  color: Colors.white,
                ),
                label: "Home"),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("assets/arduino.png"),
                  color: Colors.white,
                ),
                label: "Device"),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("assets/Add.png"),
                  color: Colors.white,
                ),
                label: "Add"),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("assets/temperature.png"),
                  color: Colors.white,
                ),
                label: "Monitor"),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("assets/History.png"),
                  color: Colors.white,
                ),
                label: "History"),
          ],
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          onTap: (index) {
            // this has changed
            setState(() {
              _selectedNavbar = index;
            });
            _onTap();
          },
        ),
        body: deviceId == model.deviceId
            ? Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/back1.png"),
                  fit: BoxFit.cover,
                ),
              ),
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              //height: 500,
              child: ListView(
                padding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        logoutButton,
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                  Text("History",
                      style:
                      TextStyle(fontSize: 36, color: Colors.white)),
                  SizedBox(height: 50),
                  model.data.isEmpty
                      ? Table(
                    defaultColumnWidth: FixedColumnWidth(120.0),
                    border: TableBorder.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 2),
                    children: [
                      TableRow(children: [
                        Column(children: [
                          Text('Time',
                              style: TextStyle(fontSize: 20.0))
                        ]),
                        Column(children: [
                          Text('Temperature &  Humidity',
                              style: TextStyle(fontSize: 20.0))
                        ]),
                      ]),
                      for (int i = 0; i <= model.data.length; i++)
                        TableRow(children: [
                          Column(children: [
                            Text(model.time[i],
                                style: TextStyle(fontSize: 20.0))
                          ]),
                          Column(children: [
                            Text(
                                model.data[i].temp +
                                    ' - ' +
                                    model.data[i].humidity,
                                style: TextStyle(fontSize: 20.0))
                          ]),
                        ]),
                    ],
                  )
                      : SizedBox(),
                ],
              ),
            )
          ],
        )
            : Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/back1.png"),
              fit: BoxFit.cover,
            ),),


          width: MediaQuery.of(context).size.width,
          child: Stack(children: [

            // For Title
            Positioned(bottom: 35, top: 450, right: 30, left: 30,
              child: Column(
                children: const [
                  Text('Please Add the Serial Number First', style: TextStyle(fontSize: 36, color: Colors.green))
                ],
              ),),
          ],),

        ),
      );
    });
  }
  //
  // LineChartData mainTempData(List<Data> data, List<String> time) {
  //   return LineChartData(
  //     gridData: FlGridData(
  //       show: true,
  //       drawVerticalLine: false,
  //       drawHorizontalLine: false,
  //       horizontalInterval: 1,
  //       verticalInterval: 1,
  //       getDrawingHorizontalLine: (value) {
  //         return FlLine(
  //           color: const Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //       getDrawingVerticalLine: (value) {
  //         return FlLine(
  //           color: const Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //     ),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       rightTitles: AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       topTitles: AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 30,
  //           interval: 1,
  //           getTitlesWidget: (double value, TitleMeta meta) {
  //             const style = TextStyle(
  //               color: Color(0xff68737d),
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //             );
  //             Widget text;
  //             switch (value.toInt()) {
  //               case 0:
  //                 text = Text(time[4].substring(0, 5), style: style);
  //                 break;
  //               case 1:
  //                 text = Text(time[3].substring(0, 5), style: style);
  //                 break;
  //               case 2:
  //                 text = Text(time[2].substring(0, 5), style: style);
  //                 break;
  //               case 3:
  //                 text = Text(time[1].substring(0, 5), style: style);
  //                 break;
  //               case 4:
  //                 text = Text(time[0].substring(0, 5), style: style);
  //                 break;
  //               default:
  //                 text = const Text('', style: style);
  //                 break;
  //             }
  //
  //             return Padding(
  //                 child: text, padding: const EdgeInsets.only(top: 8.0));
  //           },
  //         ),
  //       ),
  //       leftTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           interval: 2,
  //           getTitlesWidget: leftTitleTempWidgets,
  //           reservedSize: 42,
  //         ),
  //       ),
  //     ),
  //     borderData: FlBorderData(
  //         show: true,
  //         border: Border.all(color: const Color(0xff37434d), width: 1)),
  //     minX: 0,
  //     maxX: 5,
  //     minY: 10,
  //     maxY: 40,
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: [
  //           for (int i = data.length - 1; i >= 0; i--)
  //             FlSpot(i / 1, double.parse(data[i].temp)),
  //         ],
  //         isCurved: true,
  //         gradient: LinearGradient(
  //           colors: [
  //             const Color(0xff23b6e6),
  //             const Color(0xff02d39a),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //         barWidth: 5,
  //         isStrokeCapRound: true,
  //         dotData: FlDotData(
  //           show: true,
  //         ),
  //         belowBarData: BarAreaData(
  //           show: true,
  //           gradient: LinearGradient(
  //             colors: [
  //               const Color(0xff23b6e6),
  //               const Color(0xff02d39a),
  //             ].map((color) => color.withOpacity(0.3)).toList(),
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // LineChartData mainHumidData(List<Data> data, List<String> time) {
  //   return LineChartData(
  //     gridData: FlGridData(
  //       show: true,
  //       drawVerticalLine: false,
  //       drawHorizontalLine: false,
  //       horizontalInterval: 1,
  //       verticalInterval: 1,
  //       getDrawingHorizontalLine: (value) {
  //         return FlLine(
  //           color: const Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //       getDrawingVerticalLine: (value) {
  //         return FlLine(
  //           color: const Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //     ),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       rightTitles: AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       topTitles: AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 30,
  //           interval: 1,
  //           getTitlesWidget: (double value, TitleMeta meta) {
  //             const style = TextStyle(
  //               color: Color(0xff68737d),
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //             );
  //             Widget text;
  //             switch (value.toInt()) {
  //               case 0:
  //                 text = Text(time[4].substring(0, 5), style: style);
  //                 break;
  //               case 1:
  //                 text = Text(time[3].substring(0, 5), style: style);
  //                 break;
  //               case 2:
  //                 text = Text(time[2].substring(0, 5), style: style);
  //                 break;
  //               case 3:
  //                 text = Text(time[1].substring(0, 5), style: style);
  //                 break;
  //               case 4:
  //                 text = Text(time[0].substring(0, 5), style: style);
  //                 break;
  //               default:
  //                 text = const Text('', style: style);
  //                 break;
  //             }
  //
  //             return Padding(
  //                 child: text, padding: const EdgeInsets.only(top: 8.0));
  //           },
  //         ),
  //       ),
  //       leftTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           interval: 4,
  //           getTitlesWidget: leftTitleHumidWidgets,
  //           reservedSize: 42,
  //         ),
  //       ),
  //     ),
  //     borderData: FlBorderData(
  //         show: true,
  //         border: Border.all(color: const Color(0xff37434d), width: 1)),
  //     minX: 0,
  //     maxX: 5,
  //     minY: 60,
  //     maxY: 100,
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: [
  //           for (int i = data.length - 1; i >= 0; i--)
  //             FlSpot(i / 1, double.parse(data[i].temp)),
  //         ],
  //         isCurved: true,
  //         gradient: LinearGradient(
  //           colors: [
  //             const Color(0xff23b6e6),
  //             const Color(0xff02d39a),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //         barWidth: 5,
  //         isStrokeCapRound: true,
  //         dotData: FlDotData(
  //           show: true,
  //         ),
  //         belowBarData: BarAreaData(
  //           show: true,
  //           gradient: LinearGradient(
  //             colors: [
  //               const Color(0xff23b6e6),
  //               const Color(0xff02d39a),
  //             ].map((color) => color.withOpacity(0.3)).toList(),
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget bottomTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     color: Color(0xff68737d),
  //     fontWeight: FontWeight.bold,
  //     fontSize: 16,
  //   );
  //   Widget text;
  //   switch (value.toInt()) {
  //     case 2:
  //       text = const Text('MAR', style: style);
  //       break;
  //     case 5:
  //       text = const Text('JUN', style: style);
  //       break;
  //     case 8:
  //       text = const Text('SEP', style: style);
  //       break;
  //     default:
  //       text = const Text('', style: style);
  //       break;
  //   }
  //
  //   return Padding(child: text, padding: const EdgeInsets.only(top: 8.0));
  // }
  //
  // Widget leftTitleHumidWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     color: Color(0xff67727d),
  //     fontWeight: FontWeight.bold,
  //     fontSize: 15,
  //   );
  //   String text;
  //   switch (value.toInt()) {
  //     case 60:
  //       text = '60';
  //       break;
  //     case 64:
  //       text = '64';
  //       break;
  //     case 68:
  //       text = '68';
  //       break;
  //     case 72:
  //       text = '72';
  //       break;
  //     case 76:
  //       text = '76';
  //       break;
  //     case 80:
  //       text = '80';
  //       break;
  //     case 84:
  //       text = '84';
  //       break;
  //     case 88:
  //       text = '88';
  //       break;
  //     case 92:
  //       text = '92';
  //       break;
  //     case 96:
  //       text = '96';
  //       break;
  //     case 100:
  //       text = '100';
  //       break;
  //     default:
  //       return Container();
  //   }
  //
  //   return Text(text, style: style, textAlign: TextAlign.left);
  // }
  //
  // Widget leftTitleTempWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     color: Color(0xff67727d),
  //     fontWeight: FontWeight.bold,
  //     fontSize: 15,
  //   );
  //   String text;
  //   switch (value.toInt()) {
  //     case 10:
  //       text = '10';
  //       break;
  //     case 12:
  //       text = '12';
  //       break;
  //     case 14:
  //       text = '14';
  //       break;
  //     case 16:
  //       text = '16';
  //       break;
  //     case 18:
  //       text = '18';
  //       break;
  //     case 20:
  //       text = '20';
  //       break;
  //     case 22:
  //       text = '22';
  //       break;
  //     case 24:
  //       text = '24';
  //       break;
  //     case 26:
  //       text = '26';
  //       break;
  //     case 28:
  //       text = '28';
  //       break;
  //     case 30:
  //       text = '30';
  //       break;
  //     case 32:
  //       text = '32';
  //       break;
  //     case 34:
  //       text = '34';
  //       break;
  //     case 36:
  //       text = '36';
  //       break;
  //     default:
  //       return Container();
  //   }
  //
  //   return Text(text, style: style, textAlign: TextAlign.left);
  // }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
