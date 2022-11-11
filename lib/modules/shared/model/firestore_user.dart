class FirestoreUser {
  final String? id;
  final String displayName;
  final String email;

  FirestoreUser({
    this.id,
    required this.displayName,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      "displayName": this.displayName,
      "email": this.email,
    };
  }
}
