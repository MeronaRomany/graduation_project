import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model_auth.dart';
class UsersFireStore{
  late
  UserModel userModel;

  Future createUserToFireStore(String uid,String name, String email)async{
    var setuserData= FirebaseFirestore.instance.collection("users").doc(uid);

    Map<String, dynamic> json= {
      "uid": uid,
      "name": name,
      "email": email,

    };
    return setuserData.set(json);
  }

  Future<UserModel?> getUserFromFireStore(String uid) async {
    UserModel? getUserData;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((value) {
      if (value.exists && value.data() != null) {
        getUserData = UserModel.fromJson(value.data()!);
      }
    });

    return getUserData;
  }

}