class JWTTokenResponse{
  final String token;
  final int role;

  JWTTokenResponse({
    required this.token,
    required this.role,
  });

  factory JWTTokenResponse.fromJson(Map<String, dynamic> json) {
  return JWTTokenResponse(
    token: json['token'],
    role: json['role'],
  );
}
}