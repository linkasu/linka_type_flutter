// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) =>
    LoginUser(id: json['id'] as String, email: json['email'] as String);

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token'] as String,
      user: LoginUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    VerifyEmailRequest(
      email: json['email'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{'email': instance.email, 'code': instance.code};

ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  ResetPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

ResetPasswordVerifyRequest _$ResetPasswordVerifyRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordVerifyRequest(
  email: json['email'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$ResetPasswordVerifyRequestToJson(
  ResetPasswordVerifyRequest instance,
) => <String, dynamic>{'email': instance.email, 'code': instance.code};

ResetPasswordConfirmRequest _$ResetPasswordConfirmRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordConfirmRequest(
  email: json['email'] as String,
  code: json['code'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$ResetPasswordConfirmRequestToJson(
  ResetPasswordConfirmRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'code': instance.code,
  'password': instance.password,
};
