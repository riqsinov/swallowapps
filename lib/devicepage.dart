import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/monitorpage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';



class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  _DevicePage createState() => _DevicePage();
}

class _DevicePage extends State<DevicePage> {
  turnOn() {
    setState(() {
      value = true;
    });
  }

  turnOff() {
    setState(() {
      value = false;
    });
  }

  final dbRef = FirebaseDatabase.instance.reference();

  bool value = false;

  int _selectedNavbar = 0;

  final _pageOptions = [
    HomePage(),
    DevicePage(),
    AddPage(),
    MonitorPage(),
    HistoryPage(),
  ];

  _onTap() { // this has changed
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => _pageOptions[_selectedNavbar]));
  }

  @override
  Widget build(BuildContext context) {
    final logoutButton = Material(
      elevation: 200,
      borderRadius: BorderRadius.circular(15),
      color: Colors.green,

      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () {logout(context);},
        child: Text("Logout", textAlign: TextAlign.center, style: TextStyle(
          fontSize: 25, color: Colors.white,
        ),),
      ),
    );

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
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/arduino.png"),
                color: Colors.white,
              ),
              label: "Device"
          ),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/Add.png"),
                color: Colors.white,
              ),
              label: "Add"
          ),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/temperature.png"),
                color: Colors.white,
              ),
              label: "Monitor"
          ),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/History.png"),
                color: Colors.white,
              ),
              label: "History"
          ),
        ],
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        onTap: (index) { // this has changed
          setState(() {
            _selectedNavbar = index;
          });
          _onTap();
        },
      ),


      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back1.png"),
            fit: BoxFit.cover,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [

          Positioned(top: 40,right: 10,
            child: logoutButton,
          ),

          // For Title
          Positioned(bottom: 35, top: 150, left: 10,
            child: Column(
              children: [
                Text("View Device", style: TextStyle(fontSize: 36, color: Colors.white)),
              ],
            ),),

          Positioned( top: 350, left: 10,
            child: Column(
              children: [
                Text("Serial Device Number: ", style: TextStyle(fontSize: 19, color: Colors.green)),
              ],
            ),),

          Positioned(top: 550, left: 10,
            child: Column(
            children: [
              MaterialButton(
                color: Colors.blue,
                shape: const CircleBorder(),
                onPressed: () {
                  turnOn();
                  writeData();
                },
                child: const Padding(
                  padding: EdgeInsets.all(33),
                  child: Text(
                    'Turn On',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              )
            ],
          ),),

          Positioned( top: 550, right: 10,
            child: Column(
            children: [
              MaterialButton(
                color: Colors.red,
                shape: const CircleBorder(),
                onPressed: () {
                  turnOff();
                  writeData();
                  },
                child: const Padding(
                  padding: EdgeInsets.all(33),
                  child: Text(
                    'Turn Off',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              )
            ],
          ),),
        ],),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> writeData() async {
    dbRef.child("DHT11/Device").set({"device": value});
  }

}

