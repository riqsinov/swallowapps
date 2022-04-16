
class db {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;

  db({this.uid, this.email, this.firstName, this.lastName});

  // receiving data from server
  factory db.fromMap(map) {
    return db(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['secondName'],
    );
  }

  // sending data to our server
  Map <String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': lastName,
    };
  }
}