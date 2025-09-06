import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({required this.email, required this.password});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginUser {
  final String id;
  final String email;

  LoginUser({required this.id, required this.email});

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);
  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String token;
  final String? refreshToken;
  final LoginUser user;

  LoginResponse({required this.token, this.refreshToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String email;
  final String code;

  VerifyEmailRequest({required this.email, required this.code});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String email;

  ResetPasswordRequest({required this.email});

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordVerifyRequest {
  final String email;
  final String code;

  ResetPasswordVerifyRequest({required this.email, required this.code});

  factory ResetPasswordVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordVerifyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordVerifyRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordConfirmRequest {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordConfirmRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  factory ResetPasswordConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordConfirmRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordConfirmRequestToJson(this);
}

@JsonSerializable()
class RegisterResponse {
  final String token;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  final LoginUser user;

  RegisterResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

@JsonSerializable()
class VerifyEmailResponse {
  final String message;
  final String userId;

  VerifyEmailResponse({
    required this.message,
    required this.userId,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailResponseToJson(this);
}

@JsonSerializable()
class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordResponseToJson(this);
}

@JsonSerializable()
class ResetPasswordVerifyResponse {
  final String message;

  ResetPasswordVerifyResponse({required this.message});

  factory ResetPasswordVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordVerifyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordVerifyResponseToJson(this);
}

@JsonSerializable()
class ResetPasswordConfirmResponse {
  final String message;

  ResetPasswordConfirmResponse({required this.message});

  factory ResetPasswordConfirmResponse.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordConfirmResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordConfirmResponseToJson(this);
}

@JsonSerializable()
class ProfileResponse {
  final String userId;
  final String email;

  ProfileResponse({
    required this.userId,
    required this.email,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}
