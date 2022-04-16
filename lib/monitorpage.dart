import 'package:flutter/material.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({Key? key}) : super(key: key);

  @override
  _MonitorPage createState() => _MonitorPage();
}

class _MonitorPage extends State<MonitorPage> {
  int _selectedNavbar = 0;

  final _pageOptions = [
    new HomePage(),
    new DevicePage(),
    new AddPage(),
    new MonitorPage(),
    new HistoryPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedNavbar = index;
    });
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
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
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
        currentIndex: _selectedNavbar,
        onTap: onItemTapped,
        unselectedItemColor: Colors.green,
        showUnselectedLabels: true,
      ),


      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back1.png"),
            fit: BoxFit.cover,
          ),
        ), width: MediaQuery.of(context).size.width,
        child: Stack(children: [

          Positioned(top: 40,right: 10,
            child: logoutButton,
          ),

          // For Title
          Positioned(bottom: 35, top: 150, left: 10,
            child: Column(
              children: [
                Text("Temperature & \n Humidity", style: TextStyle(fontSize: 36, color: Colors.white)),
              ],
            ),),

          Positioned(bottom: 35, top: 300, left: 20,
              child: Column(
              children: [
              Text("Temperature", style: TextStyle(fontSize: 32, color: Colors.green)),
            ],
          ),),

          Positioned(bottom: 35, top: 300, right: 40,
            child: Column(
              children: [
                Text("Humidity", style: TextStyle(fontSize: 32, color: Colors.green,)),
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
}