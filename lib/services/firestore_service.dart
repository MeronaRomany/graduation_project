import 'dart:developer';

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
      'name': (await getUserFromFireStore(userId))?.name,
      'email': (await getUserFromFireStore(userId))?.email,
      'callerId': userId,
      'receiverId': null,
      'channelId': channelId,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromQueue(String userId) async {
   await FirebaseFirestore.instance.collection('chat_practice_queue').doc(userId).delete();
  }

  Stream<List<UserModel>> getWaitingUsers() {
    return FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .where('status', isEqualTo: 'waiting').limit(3)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // Include document ID for reference
              return UserModel.fromJson(data);
            }).toList());
  }

  Future<void> joinSpecificMatch(String myUserId, String targetUserId, String channelId) async {
    final docRef = FirebaseFirestore.instance.collection('chat_practice_queue').doc(targetUserId);
    final doc = await docRef.get();
    if (doc.exists && doc.data()?['status'] == 'waiting') {
      await docRef.update({
        'status': 'matched',
        'receiverId': myUserId,
        'matchedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String?> findMatch(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      log("querySnapshot.docs.isNotEmpty");
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
    log("before addToQueue");
    await addToQueue(userId, "testgroup1");
    return null;
  }

}