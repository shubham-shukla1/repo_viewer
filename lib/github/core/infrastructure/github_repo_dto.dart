import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/domain/user.dart';
import 'package:repo_viewer/github/core/infrastructure/user_dto.dart';

part 'github_repo_dto.g.dart';
part 'github_repo_dto.freezed.dart';

String _descriptionFromJson(Object? json) {
  return (json as String?) ?? "";
}

@freezed
class GithubRepoDTO with _$GithubRepoDTO {
  //with this dto , only user dto is allowed
  const GithubRepoDTO._();
  const factory GithubRepoDTO({
    //all the filed are according to the key only count is not os use jsonKey
    required UserDTO owner,
    required String name,
    //everything in json annotation constructor needs to be constant
    //
    @JsonKey(fromJson: _descriptionFromJson) required String description,
    @JsonKey(name: 'stargazers_count') required int stargazersCount,
  }) = _GithubRepoDTO;

  factory GithubRepoDTO.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDTOFromJson(json);

//domain accept githubRepo entities in constructor,
//from Json is not enough so take DTO and make into entities and similar take entities convert into DTO
//inside DTO class because this is unclean class that contains
//all of the conversion methods so keep  entities clean 
///from domain layer to infrastructure layer
  factory GithubRepoDTO.fromDomain(GithubRepo _) {
    return GithubRepoDTO(
        owner: UserDTO.fromDomain(_.owner),
        name: _.name,
        description: _.description,
        stargazersCount: _.stargazersCount);
  }
  //Dto to  entities

  GithubRepo toDomain() {
    return GithubRepo(
        owner: owner.toDomain(),
        name: name,
        description: description,
        stargazersCount: stargazersCount);
  }
}
