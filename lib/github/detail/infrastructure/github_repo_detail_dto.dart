import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/detail/domain/github_repo_detail.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

part 'github_repo_detail_dto.freezed.dart';
part 'github_repo_detail_dto.g.dart';

//DTO can be used to take JSON directly from the response
//and convert that json to dto directly
//we really map the json response one to one to the respected dto
//we can use generated fromJson and toJson method
//we do not need to worry about the data which is coming from the server
//we do not need to use any json annotation

@freezed
class GithubRepoDetailDTO with _$GithubRepoDetailDTO {
  const GithubRepoDetailDTO._();
  const factory GithubRepoDetailDTO({
    required String fullName,
    required String html,
    required bool starred,
  }) = _GithubRepoDetailDTO;

  //fromJson from the local cache

  factory GithubRepoDetailDTO.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDetailDTOFromJson(json);

//it returns entity type means which are clean in domain
//DTO basically is for conversion logic for database
//Always create DTO even if seems boring as we have fields as same in entity
//include fromJson and own methods in dto only
  GithubRepoDetail toDomain() => GithubRepoDetail(
        fullName: fullName,
        html: html,
        starred: starred,
      );

  static const lastUsedFieldName = 'lastUsed';

  Map<String, dynamic> toSembast() {
    final json = toJson();
    json.remove('fullName');
    json[lastUsedFieldName] = Timestamp.now();
    return json;
  }

  factory GithubRepoDetailDTO.fromSembast(
    RecordSnapshot<String, Map<String, dynamic>> snapshot,
  ) {
    final copiedMap = Map<String, dynamic>.from(snapshot.value);
    copiedMap['fullName'] = snapshot.key;
    return GithubRepoDetailDTO.fromJson(copiedMap);
  }
}
