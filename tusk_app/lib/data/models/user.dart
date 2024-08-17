class User {
  final int? id;
  final String? role;
  final String? name;
  final String? email;

  User({
    this.id,
    this.role,
    this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        role: json["role"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "role": role,
        "name": name,
        "email": email,
      };
}
