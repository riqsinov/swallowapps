import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swallow_monitoring/loginpage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator. pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/back.png"),
          fit: BoxFit.cover,
        ),
      ),


      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        // For Background
        Positioned( top: 350,  left: 180,
          child: Column(
            children: [
              Image.asset('assets/swallow.png', width: 160, height: 160,),

            ],
          ),),

        // For Title
        Positioned(bottom: 35, top: 350, right: 175, left: 20,
          child: Column(
            children: const [
              Text('Monitoring \nSwallow \nNest', style: TextStyle(fontSize: 27, color: Colors.green))
            ],
          ),),
      ],),

    ),
  );
  }
}