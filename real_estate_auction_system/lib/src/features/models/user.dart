class User {
  final String fullName;
  final String userName;
  final String phone;
  final String email;
  final DateTime doB;
  User(
      {required this.fullName,
      required this.userName,
      required this.phone,
      required this.email,
      required this.doB,});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'],
      userName: json['userName'],
      phone: json['phone'],
      email: json['email'],
      doB: DateTime.parse(json['doB'] as String)
    );
  }
}
