import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/loginpage.dart';
import 'package:swallow_monitoring/monitorpage.dart';
import 'package:swallow_monitoring/datamodel.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPage createState() => _AddPage();
}

class _AddPage extends State<AddPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController deviceController = TextEditingController();

  int _selectedNavbar = 0;

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
    final devicedField = TextFormField(
      autofocus: false,
      controller: deviceController,
      validator: (value) {
        RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9]).{11,}$');
        if(value!.isEmpty)
        {
          return ("Please Enter The Serial Number");
        }
        if (!regex.hasMatch(value)) {
          return ("Please Enter Correct Serial Number");
        }
      },
      onSaved: (value)
      {
        deviceController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: " ",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );

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

    final submitButton = Material(
      elevation: 200,
      borderRadius: BorderRadius.circular(15),
      color: Colors.green,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () async {
          SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
          sharedPreferences.setString('device_Id', deviceController.text);
        },
        child: Text(
          "Submit",
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
          child: Container(
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment(1, 10),
                        child: logoutButton,
                      ),
                      SizedBox(height: 150),
                      const Align(
                        alignment: Alignment(-1, 0),
                        child: Text('Add Device',
                            style:
                            TextStyle(fontSize: 36, color: Colors.white)),
                      ),
                      SizedBox(height: 150),
                      const Align(
                        alignment: Alignment(-0.95, 0),
                        child: Text('Device Serial Number',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      devicedField,
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment(0, 0),
                        child: submitButton,
                      ),
                      SizedBox(height: 330),
                    ]),
              ),
            ),
          )),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
