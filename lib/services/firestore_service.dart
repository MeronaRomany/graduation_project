import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_app/services/user_storage_services.dart';
import '../models/user_model_auth.dart';
import '../models/learning_session_model.dart';

class FireStoreService {
  final UserStorageService _userStorageService = UserStorageService();

  Future<UserModel> get userModel async {
    final user = await _userStorageService.getUser();
    return UserModel(
      uid: user['uid'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      level: user['level'] ?? 'A1',
    );
  }

  Future<void> createUserToFireStore(String uid, String name, String email) async {
    var setuserData = FirebaseFirestore.instance.collection("users").doc(uid);
    Map<String, dynamic> json = {
      "uid": uid,
      "name": name,
      "email": email,
    };
    return setuserData.set(json);
  }

  Future<UserModel?> getUserFromFireStore(String uid) async {
    UserModel? getUserData;
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then((value) {
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
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update(updates);
    }
  }

  Future<void> deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).delete();
  }

  Future<void> saveLearningSession(LearningSession session) async {
    await FirebaseFirestore.instance
        .collection('learning_sessions')
        .add(session.toMap());
  }

  Stream<List<LearningSession>> streamLearningSessions(String userId) {
    return FirebaseFirestore.instance
        .collection('learning_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LearningSession.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<LearningSession>> getLearningSessionsByRange(String userId, DateTime start) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('learning_sessions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => LearningSession.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addToQueue(String channelId) async {
    final user = await userModel;
    await FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .doc(user.uid)
        .set({
      'name': user.name,
      'email': user.email,
      'callerId': user.uid,
      'receiverId': null,
      'channelId': channelId,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromQueue() async {
    final user = await userModel;
    await FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .doc(user.uid)
        .delete();
  }

  Stream<List<UserModel>> getWaitingUsers() {
    return FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .where('status', isEqualTo: 'waiting')
        .limit(3)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return UserModel.fromJson(data);
            }).toList());
  }

  Future<String?> findMatch() async {
    final user = await userModel;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_practice_queue')
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      if (doc.id != user.uid) {
        await doc.reference.update({
          'status': 'matched',
          'receiverId': user.uid,
          'matchedAt': FieldValue.serverTimestamp(),
        });
        await removeFromQueue();
        return doc.data()['channelId'];
      }
    }
    return null;
  }
}
