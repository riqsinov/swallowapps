// class Sensor {
//   final double temp;
//   final double humidity;
//
//   Sensor({this.temp, this.humidity});
//
//   factory Sensor.fromJson(Map<dynamic, dynamic> json) {
//     double parser(dynamic source) {
//       try {
//         return double.parse(source.toString());
//       } on FormatException {
//         return -1;
//       }
//     }
//
//     return Sensor(
//         temp: parser(json['Temperature']),
//         humidity: parser(json['Humidity'])),
//   }
// }