
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payfond/model/FirebaseModel/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.User> getUserDetails(t) async {

    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
    await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User
  Future<String> signUpUser({
    required String firstName,
    required String lastName,
    required String mobileNo,
    required String email,
    required String password,
    required bool userActive,
    required String userSalt,
    required DateTime userCreationDate,
    required int userLoginTime,
    required bool isAdmin
  }) async {
    String res = "Some error Occurred";
    try {
      if (firstName.isNotEmpty || lastName.isNotEmpty || mobileNo.isNotEmpty || email.isNotEmpty || password.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _auth.currentUser!.updateDisplayName('$firstName $lastName');
        await _auth.currentUser!.updateEmail(email);
        await _auth.currentUser!.updatePassword(password);


        model.User user = model.User(
          uid: cred.user!.uid,
          firstName: firstName,
          lastName: lastName,
          mobileNo: mobileNo,
          email: email,
          password: password,
          userActive: userActive,
          userSalt: userSalt,
          userCreationDate: userCreationDate,
          userLoginTime: userLoginTime,
          isAdmin: isAdmin,

        );

        // adding user in our database
        await _firestore.collection("users").doc(cred.user!.uid).set(user.toJson());

        res = "success";
      }
      else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch(e) {

      if(e.code == 'weak-password'){
        res = e.code;
        return res;
      }
    }
    catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      }
      else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
