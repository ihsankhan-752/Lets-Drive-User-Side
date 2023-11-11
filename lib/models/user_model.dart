import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? name;
  String? phone;
  String? id;
  String? email;

  UserModel({this.id, this.email, this.name, this.phone});

  UserModel.fromSnapshot(DataSnapshot snap) {
    id = snap.key;
    name = (snap.value as dynamic)['name'];
    email = (snap.value as dynamic)['email'];
    phone = (snap.value as dynamic)['phone'];
  }
}
