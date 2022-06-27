import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastrcture/networ_exception.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/extension.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/infrastructure/starred_repos_remote_service.dart';

import '../../../../core/infrastructure/github_repo_dto.dart';

class StarredReposRepository {
  final StarredReposRemoteService _remoteService;
  final StarredReposLocalService _localService;

  StarredReposRepository(this._remoteService, this._localService);
  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
      int page) async {
    try {
      final remotePageItems = await _remoteService.getStarredReposPage(page);
      return right(await remotePageItems.when(
          // in case of no connection always load data from local cache,no connection dat is not fresh
          //we get max page from no connection
          noConnection: (() async => Fresh.no(
              //await something inside of nested function?
              await _localService.getPage(page).then((_) => _.toDomain()),
              isNextPageAvailable: page < await _localService.getLocalPageCount())),
          //in not modified we have got 304 code ,
          notModified: ((maxPage) async => Fresh.yes(
              await _localService.getPage(page).then((_) => _.toDomain()),
              isNextPageAvailable: page < maxPage)),
          withNewData: (data, maxPage) async {
            //save data in local service
            await _localService.upsertPage(data, page);
            //convert list dto into list entities
            return Fresh.yes(data.toDomain(),
                isNextPageAvailable: page < maxPage);
          }));
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}



