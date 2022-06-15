import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/data_model.dart';
import 'package:swallow_monitoring/db/db.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/loginpage.dart';
import 'package:swallow_monitoring/monitorpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  db logedinuser = db();
  bool value = false;

  int _selectedNavbar = 0;

  final _pageOptions = [
    HomePage(),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(3), child: DevicePage()),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(3), child: DevicePage()),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(2), child: AddPage()),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(0), child: MonitorPage()),
    ChangeNotifierProvider<DataModel>(
        create: (_) => DataModel(1), child: HistoryPage()),
  ];

  final dbRef = FirebaseDatabase.instance.reference();

  _onTap() {
    // this has changed
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => _pageOptions[_selectedNavbar]));
  }

  onUpdate() {
    setState(() {
      value = !value;
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
      body: Container(
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
              top: 150,
              left: 10,
              child: Column(
                children: [
                  Text("Hello, ${logedinuser.firstName}",
                      style: TextStyle(fontSize: 36, color: Colors.white)),
                ],
              ),
            ),

            Positioned(
              bottom: 50,
              top: 280,
              left: 20,
              right: 20,
              child: GridView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green),
                    child: Column(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/power.png',
                            color: !value ? Colors.red : Colors.white,
                          ),
                          iconSize: 30,
                          onPressed: () {
                            onUpdate();
                            writeData();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> writeData() async {
    dbRef.child("DHT11/Device").set({"device": value});
  }
}