import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model_auth.dart';
class FireStoreService{

  Future createUserToFireStore(String uid,String name, String email)async{
    var setuserData= await FirebaseFirestore.instance.collection("users").doc(uid);

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

   Future<void> addToQueue(String userId, String channelId) async {
    await FirebaseFirestore.instance.collection('chat_practice_queue').doc(userId).set({
      'callerId': userId,
      'receiverId': null,
      'channelId': channelId,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromQueue(String userId) async {
   // await FirebaseFirestore.instance.collection('chat_practice_queue').doc(userId).delete();
  }

  Future<String?> findMatch(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      if (doc.id != userId) {
        await doc.reference.update({
          'status': 'matched',
          'receiverId': userId,
          'matchedAt': FieldValue.serverTimestamp(),
        });
        return doc.data()['channelId'];
      }
    } 
    await addToQueue(userId, "testgroup1");
    return null;
  }

}