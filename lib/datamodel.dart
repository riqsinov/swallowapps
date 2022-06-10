import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Data {
  final String temp;
  final String humidity;

  Data({required this.temp, required this.humidity});

  factory Data.fromRTDB(Map<String, dynamic> data) {
    return Data(temp: data['Temperature'], humidity: data['Humidity']);
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
  List<String> _time = [''];
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
    else
      _listenToPeriodicData();
  }

  //final DataModel dataModel = DataModel();

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
    List<Data> x = List<Data>.empty(growable: true);
    List<String> y = List<String>.empty(growable: true);
    for (int i = 0; i <= 4; i++) {
      DateTime roundedDateTime = DateTime.now()
          .subtract(Duration(hours: i))
          .roundDown(delta: Duration(hours: 1));
      String time = roundedDateTime.toString().split(' ')[1].substring(0, 8);
      y.add(time);
      db.orderByKey().equalTo(time).get().then((event) {
        if (event.value != null) {
          var dataMap = Map<String, dynamic>.from(event.value as dynamic);
          Data temp_data = dataMap.values
              .map((e) => Data.fromRTDB(Map<String, dynamic>.from(e)))
              .first;
          x.add(temp_data);
        }
      });
    }
    _data = x;
    _time = y;
    notifyListeners();
  }

  @override
  void dispose() {
    _lastDataStream.cancel();
    super.dispose();
  }
}

extension on DateTime {
  DateTime roundDown({Duration delta = const Duration(seconds: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(this.millisecondsSinceEpoch -
        this.millisecondsSinceEpoch % delta.inMilliseconds);
  }
}
