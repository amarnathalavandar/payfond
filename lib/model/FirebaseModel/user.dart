import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String mobileNo;
  final String email;
  final String password;
  final bool userActive;
  final String userSalt;
  final DateTime userCreationDate;
  final int userLoginTime;
  final bool isAdmin;

  const User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.mobileNo,
    required this.email,
    required this.password,
    required this.userActive,
    required this.userSalt,
    required this.userCreationDate,
    required this.userLoginTime,
    required this.isAdmin
});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      uid: snapshot["uid"],
      firstName: snapshot["firstName"],
      lastName: snapshot["lastName"],
      email: snapshot["email"],
      mobileNo: snapshot["mobileNo"],
      password: snapshot["password"],
      userActive: snapshot["userActive"],
      userSalt: snapshot["userSalt"],
      userCreationDate: snapshot["userCreationDate"],
      userLoginTime: snapshot["userLoginTime"],
      isAdmin: snapshot["isAdmin"]
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "firstName" : firstName,
    "lastName" : lastName,
    "mobileNo" : mobileNo,
    "email" : email,
    "password" : password,
    "userActive": userActive,
    "userSalt": userSalt,
    "userCreationDate": userCreationDate,
    "userLoginTime": userLoginTime,
    "isAdmin" : isAdmin
  };
}
