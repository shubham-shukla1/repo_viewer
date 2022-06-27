import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/infrastructure/starred_repos_repositorry.dart';

import '../../../../../core/domain/fresh.dart';
import '../../../../core/domain/github_repo.dart';
part 'starred_repos_notifier.freezed.dart';

@freezed
class StarredReposState with _$StarredReposState {
  const StarredReposState._();
  //Fresh<List<GithubRepo>> repos required in initial state?
  //if every one of the union case has same field,same name,exact same type
  //then whole union containing class contain that field(eg repos here ,
  //if removed from any field ,it will not be accessible)
  const factory StarredReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory StarredReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerPage,
  ) = _LoadInProgress;
  //notifiers also communicate with  presentation layer through methods
// isNextPageAvailable we are  including in success state ,if load is in progress we do not include there
  const factory StarredReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool isNextPageAvailable,
  }) = _LoadSuccess;
  //notifiers also communicate with  domain like failures and infrastructure layer through methods
//might happen first 2 pages load successfully and then error,in such case failure for 3 rd page
//put list
  const factory StarredReposState.loadFailure(
    GithubFailure failure,
    Fresh<List<GithubRepo>> repos,
  ) = _Failure;
}

//only thing presentation layer should do is to get its states available from states union
class StarredReposNotifier extends StateNotifier<StarredReposState> {
  final StarredReposRepository _repository;

  StarredReposNotifier(this._repository)
      : super(
          StarredReposState.initial(
            Fresh.yes([]),
          ),
        );
  //sometimes mutable field using directly in class is fine
  int _page = 1;
  Future<void> getNextStarredReposPage() async {
    state = StarredReposState.loadInProgress(
        state.repos, PaginationConfig.itemsPerPage);
    final failureOrRepos = await _repository.getStarredReposPage(_page);
    state = failureOrRepos.fold(
      //not increment the page unless successful
      (l) => StarredReposState.loadFailure(l, state.repos),
      (r) {
        _page++;
        return StarredReposState.loadSuccess(
          r.copyWith(
            entity: [...state.repos.entity, ...r.entity],
          ),
          isNextPageAvailable: r.isNextPageAvailable ?? false,
        );
      },
    );
  }
}
