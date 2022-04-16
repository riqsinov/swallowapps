import 'package:flutter/material.dart';
import 'package:swallow_monitoring/adddevicepage.dart';
import 'package:swallow_monitoring/devicepage.dart';
import 'package:swallow_monitoring/historypage.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/welcomepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swallow_monitoring/monitorpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swallow Applications',
      debugShowCheckedModeBanner: false,
      home: DevicePage(),
    );
  }
}

