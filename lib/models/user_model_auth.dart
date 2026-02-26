class UserModel {
  final String uid;
  final String name;
  final String email;

  UserModel({required this.uid, required this.name, required this.email});

  Map<String, dynamic> toJson() {
    return {"uid": uid,
      "name": name,
      "email": email};
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"] ?? '',
      name: json["name"] ?? '',
      email: json["email"] ?? '',
    );
  }
}
