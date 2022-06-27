import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/user.dart';
part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDTO with _$UserDTO {
  const UserDTO._();
  const factory UserDTO(
      {
      //tell code generation that names inside the field of our class UserDTO
      //and names of the field in the json object do not match
      //solution: with JsonKey annotation

      // ignore: invalid_annotation_target
      @JsonKey(name: 'login') required String name,
      // ignore: invalid_annotation_target
      @JsonKey(name: 'avatar_url') required String avatarUrl}) = _UserDTO;
  //Parse json as map ,we need to convert Map<String, dynamic> data into our dart class , most naive approach
  // is create factory constructor fromJson which would take in Map<String, dynamic> call json
  //from this factory constructor we need to parse json object
  /*  factory UserDTO.fromJson(Map<String, dynamic> json) {
    // name gotten from json[login] key and convert it to string
    return UserDTO(
        name: json['login'] as String, avatarUrl: json['avatar_url'] as String);
  } */
  //using json serializable makes it easy
  factory UserDTO.fromJson(Map<String, dynamic> json) =>
      _$UserDTOFromJson(json);

  factory UserDTO.fromDomain(User _) {
    return UserDTO(name: _.name, avatarUrl: _.avatarUrl);
  }

  User toDomain() {
    return User(name: name, avatarUrl: avatarUrl);
  }
}
