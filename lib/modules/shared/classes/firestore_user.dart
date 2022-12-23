class FirestoreUser {
  final String? id;
  final String displayName;
  final String email;

  FirestoreUser({
    this.id,
    required this.displayName,
    required this.email,
  });

  static FirestoreUser fromJson(Map<String, dynamic> json) {
    return FirestoreUser(
      id: json["id"],
      displayName: json["displayName"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "displayName": this.displayName,
      "email": this.email,
    };
  }
}
