class UserModel {
  final String uid;
  final String name;
  final String email;
  final String level;

  const UserModel(
      {required this.uid,
      required this.name,
      required this.email,
      required this.level});

  Map<String, dynamic> toJson() {
    return {"uid": uid, "name": name, "email": email, "level": level};
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      level: json["level"] ?? '',
      uid: json["uid"] ?? '',
      name: json["name"] ?? '',
      email: json["email"] ?? '',
    );
  }
}
