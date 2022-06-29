import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/data_model.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/loginpage.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({Key? key}) : super(key: key);

  @override
  _MonitorPage createState() => _MonitorPage();
}

class _MonitorPage extends State<MonitorPage> {
  int _selectedNavbar = 0;
  String temp = '';
  String humid = '';
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

  Color tempColor(double temp) {
    if (temp > 31) {
      return Colors.red;
    } else if (temp < 26) {
      return Colors.blue;
    } else
      return Colors.green;
  }

  Color humidColor(double humid) {
    if (humid < 80) {
      return Colors.red;
    }else if (humid > 90) {
      return Colors.blue;
    } else
      return Colors.green;
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
            setState(() {
              _selectedNavbar = index;
            });
            _onTap();
          },
        ),
        body: deviceId == model.deviceId
            ? Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/back1.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      right: 10,
                      child: logoutButton,
                    ),

                    // For Title
                    Positioned(
                      bottom: 35,
                      top: 110,
                      left: 10,
                      child: Column(
                        children: [
                          Text("Temperature & \n Humidity",
                              style:
                                  TextStyle(fontSize: 36, color: Colors.white)),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 35,
                      top: 300,
                      left: 20,
                      child: Column(
                        children: [
                          Text("Temperature",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                              )),
                          Text(model.lastData.first.temp + "°C",
                              style: TextStyle(
                                fontSize: 40,
                                color: tempColor(
                                    double.parse(model.lastData.first.temp)),
                              ))
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 35,
                      top: 300,
                      right: 40,
                      child: Column(
                        children: [
                          Text("Humidity",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                              )),
                          Text(model.lastData.first.humidity + '%',
                              style: TextStyle(
                                fontSize: 40,
                                color: humidColor(double.parse(
                                    model.lastData.first.humidity)),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
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
