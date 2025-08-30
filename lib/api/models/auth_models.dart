import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({
    required this.email,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginUser {
  final String id;
  final String email;

  LoginUser({
    required this.id,
    required this.email,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) => _$LoginUserFromJson(json);
  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String token;
  final LoginUser user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String email;
  final String code;

  VerifyEmailRequest({
    required this.email,
    required this.code,
  });

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String email;

  ResetPasswordRequest({
    required this.email,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordVerifyRequest {
  final String email;
  final String code;

  ResetPasswordVerifyRequest({
    required this.email,
    required this.code,
  });

  factory ResetPasswordVerifyRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordVerifyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordVerifyRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordConfirmRequest {
  final String email;
  final String code;
  final String password;

  ResetPasswordConfirmRequest({
    required this.email,
    required this.code,
    required this.password,
  });

  factory ResetPasswordConfirmRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordConfirmRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordConfirmRequestToJson(this);
}
