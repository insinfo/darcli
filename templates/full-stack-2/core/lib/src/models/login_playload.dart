class LoginPayload {
  String login;
  String password;
  LoginPayload({
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'login': login,
      'password': password,
    };
  }

  factory LoginPayload.fromMap(Map<String, dynamic> map) {
    return LoginPayload(
      login: map['login'],
      password: map['password'],
    );
  }
}
