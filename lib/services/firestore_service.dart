import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_app/services/user_storage_services.dart';

import '../models/user_model_auth.dart';
import '../models/session_evaluation_model.dart';
class FireStoreService{
  final UserStorageService _userStorageService = UserStorageService();

  Future<UserModel> get userModel async =>  UserModel(
    uid: (await _userStorageService.getUser())['uid'],
    name: (await _userStorageService.getUser())['name'],
    email: (await _userStorageService.getUser())['email'],
    level: (await _userStorageService.getUser())['level'],
  );

  Future<void> createUserToFireStore(String uid,String name, String email)async{
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

  Future<void> updateUser(String uid, {String? name, String? email}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance.collection("users").doc(uid).update(updates);
    }
  }

  Future<void> deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).delete();
  }

   Future<void> addToQueue(String channelId) async {
    await FirebaseFirestore.instance.collection('chat_practice_queue').doc(((await userModel).uid)).set({
      'name': (await userModel).name,
      'email': (await userModel).email,
      'callerId': (await userModel).uid,
      'receiverId': null,
      'channelId': channelId,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromQueue() async {
   await FirebaseFirestore.instance.collection('chat_practice_queue').doc(((await userModel).uid)).delete();
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

  Future<String?> findMatch() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      log("querySnapshot.docs.isNotEmpty");
      final doc = querySnapshot.docs.first;
      if (doc.id != (await userModel).uid ) {
        await doc.reference.update({
          'status': 'matched',
          'receiverId': (await userModel).uid,
          'matchedAt': FieldValue.serverTimestamp(),
        });
        await removeFromQueue();
        return doc.data()['channelId'];
      }
    } 
    log("before addToQueue");
    await addToQueue( "testgroup1");
    return null;
  }

  Future<void> saveSessionEvaluation(SessionEvaluation evaluation) async {
    final uid = evaluation.userId;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('session_evaluations')
        .add(evaluation.toMap());
  }

  Future<List<SessionEvaluation>> getSessionEvaluations(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('session_evaluations')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return SessionEvaluation.fromMap(doc.data(), doc.id);
    }).toList();
  }
}