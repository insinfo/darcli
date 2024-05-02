import 'package:new_sali_core/src/models/base_model.dart';

/// DTO para enviar dados referente ao pedido de autenticação
class LoginPayload implements BaseModel {
  String username;
  String password;
  String anoExercicio;

  LoginPayload({
    required this.username,
    required this.password,
    required this.anoExercicio,
  });

  set anoExercicioAsInt(int? ano) {
    anoExercicio = ano.toString();
  }

  int? get anoExercicioAsInt => int.tryParse(anoExercicio) ;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'password': password,
      'anoExercicio': anoExercicio,
    };
  }

  factory LoginPayload.fromMap(Map<String, dynamic> map) {
    return LoginPayload(
      username: map['username'],
      password: map['password'],
      anoExercicio: map['anoExercicio'],
    );
  }
}
