class GoogleUser {
  String? email = "";
  String? photoURL = "";
  String? id = "";

  GoogleUser({required this.email, required this.photoURL, required this.id});

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "email": this.email,
      "photo": this.photoURL,
    };
  }
}