import 'package:repo_viewer/core/infrastrcture/networ_exception.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/extension.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repo_remote_service.dart';
import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';

class SearchedReposRepository {
  final SearchedRepoRemoteService _remoteService;

  SearchedReposRepository(this._remoteService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getSearchedReposPage(
      String query, int page) async {
    try {
      final remotePageItems =
          await _remoteService.getSearchedReposPage(query, page);
      //not when , we use mayBeWhen coz,since there is no local data for searched repo
      //for searched , there is no etag, so no modified data
      return right(
        remotePageItems.maybeWhen(
            orElse: () => Fresh.no([], isNextPageAvailable: false),
            withNewData: (data, maxPage ) => Fresh.yes(
                  data.toDomain(),
                  isNextPageAvailable: page<maxPage,
                )),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
