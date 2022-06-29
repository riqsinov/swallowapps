import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/data_model.dart';
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
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(3), child: DevicePage()),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(2), child: AddPage()),
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
                        SizedBox(height: 40),
                        Text("History",
                            style:
                                TextStyle(fontSize: 36, color: Colors.white)),
                        SizedBox(height: 50),
                        model.data.isNotEmpty
                            ? Table(
                                defaultColumnWidth: FixedColumnWidth(120.0),
                                border: TableBorder.all(
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                    width: 2),
                                children: [
                                  TableRow(children: [
                                    Column(children: [
                                      Text('Date & Time',
                                          style: TextStyle(fontSize: 20.0))
                                    ]),
                                    Column(children: [
                                      Text('Temperature &  Humidity',
                                          style: TextStyle(fontSize: 20.0))
                                    ]),
                                  ]),
                                  for (int i = 0; i < model.data.length; i++)
                                    TableRow(children: [
                                      Column(children: [
                                        Text(model.time[i],
                                            style: TextStyle(fontSize: 20.0))
                                      ]),

                                      Column(children: [
                                        Text(
                                              model.data[i].temp + ' °C ' +
                                              ' & ' +
                                              model.data[i].humidity + ' % ',
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
            Positioned(bottom: 35, top: 420, right: 30, left: 30,
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

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
