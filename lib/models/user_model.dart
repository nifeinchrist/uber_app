import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;
  String? address;

  Users({this.id, this.email, this.name, this.phone, this.address});

  Users.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    var data = snapshot.value as Map?;
    if (data != null) {
      email = data["email"];
      name = data["name"];
      phone = data["phone"];
      address = data["address"];
    }
  }
}
