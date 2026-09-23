import 'package:auth_data/src/dto/user_dto.dart';
import 'package:auth_domain/auth_domain.dart';

extension UserDtoMapper on UserDto {
  User toEntity() => User(id: id, email: email, displayName: displayName);
}
