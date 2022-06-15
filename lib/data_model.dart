import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  final String temp;
  final String humidity;

  Data({required this.temp, required this.humidity});

  factory Data.fromRTDB(Map<String, dynamic> data) {
    return Data(
        temp: data['Temperature'] ?? '0', humidity: data['Humidity'] ?? '0');
  }
}

class Id {
  final String id;

  Id({required this.id});

  factory Id.fromRTDB(Map<String, dynamic> data) {
    return Id(id: data['DeviceID']);
  }
}

class DataModel extends ChangeNotifier {
  List<Data> _data = [Data(temp: '0', humidity: '0')];
  List<String> _time = ['0'];
  List<Data> _lastData = [Data(temp: '0', humidity: '0')];
  String id = '';
  final db = FirebaseDatabase.instance.ref().child("DHT11/Data");
  late StreamSubscription _lastDataStream;
  late StreamSubscription _periodicDataStream;

  List<Data> get data => _data;
  List<String> get time => _time;
  List<Data> get lastData => _lastData;
  String get deviceId => id;

  DataModel(int check) {
    _checkId();
    if (check == 0)
      _listenToLastData();
    else if (check == 1) _listenToPeriodicData();
  }

  //final DataModel dataModel = DataModel();

  void addUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token')!;
    final dbUser = FirebaseDatabase.instance.ref().child("DHT11/users");
    await dbUser.set({token: 'yes'});
    notifyListeners();
  }

  void _checkId() async {
    final dbId = FirebaseDatabase.instance.ref().child("DHT11/DeviceID");
    await dbId.once().then((event) {
      if (event.snapshot.value != null) {
        id = event.snapshot.value.toString();
      }
    });
    notifyListeners();
  }

  void _listenToLastData() {
    _lastDataStream = db.limitToLast(1).onValue.listen((event) {
      print(event.snapshot.value);
      if (event.snapshot.value != null) {
        final lastDataMap =
        Map<String, dynamic>.from(event.snapshot.value as dynamic);
        _lastData = lastDataMap.values
            .map((e) => Data.fromRTDB(Map<String, dynamic>.from(e)))
            .toList();
        notifyListeners();
      }
    });
  }

  void _listenToPeriodicData() {
    DateTime start = DateTime.now().subtract(Duration(hours: 24));
    String startTime = start.toString().substring(0, 19);
    print(startTime);
    db.orderByKey().once().then((event) {
      //print(event.snapshot.value);
      if (event.snapshot.value != null) {
        final dataMap =
        Map<String, dynamic>.from(event.snapshot.value as dynamic);
        final sortedKeysAsc = SplayTreeMap<String, dynamic>.from(
            dataMap, (keys1, keys2) => keys1.compareTo(keys2));
        _data = sortedKeysAsc.values
            .map((e) => Data.fromRTDB(Map<String, dynamic>.from(e)))
            .toList();
        _time = sortedKeysAsc.keys.toList();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _lastDataStream.cancel();
    _periodicDataStream.cancel();
    super.dispose();
  }
}
