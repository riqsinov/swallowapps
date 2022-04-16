import 'package:flutter/material.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/loginpage.dart';
import 'package:swallow_monitoring/monitorpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swallow_monitoring/db.dart';

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  User? user = FirebaseAuth.instance.currentUser;
  db logedinuser = db();

  int _selectedNavbar = 0;

  final _pageOptions = [
    HomePage(),
    DevicePage(),
    AddPage(),
    MonitorPage(),
    HistoryPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.logedinuser = db.fromMap(value.data());
      setState(() {});
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
      // body:
      // _pageOptions[_selectedNavbar],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex : _selectedNavbar,
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
        onTap: (index) {
          setState(() {
            _selectedNavbar = index;
          });
        },
        unselectedItemColor: Colors.green,
      ),

      body:
      Container(
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
                Text("Hello, ${logedinuser.firstName}", style: TextStyle(fontSize: 36, color: Colors.white)),
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
