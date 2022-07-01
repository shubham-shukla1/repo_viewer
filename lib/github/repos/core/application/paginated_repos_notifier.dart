import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';

import '../../../../../core/domain/fresh.dart';
import '../../../core/domain/github_repo.dart';
part 'paginated_repos_notifier.freezed.dart';

typedef RepositoryGetter
    = Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> Function(int page);

@freezed
class PaginatedReposState with _$PaginatedReposState {
  const PaginatedReposState._();
  //Fresh<List<GithubRepo>> repos required in initial state?
  //if every one of the union case has same field,same name,exact same type
  //then whole union containing class contain that field(eg repos here ,
  //if removed from any field ,it will not be accessible)
  const factory PaginatedReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory PaginatedReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerPage,
  ) = _LoadInProgress;
  //notifiers also communicate with  presentation layer through methods
// isNextPageAvailable we are  including in success state ,if load is in progress we do not include there
  const factory PaginatedReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool isNextPageAvailable,
  }) = _LoadSuccess;
  //notifiers also communicate with  domain like failures and infrastructure layer through methods
//might happen first 2 pages load successfully and then error,in such case failure for 3 rd page
//put list
  const factory PaginatedReposState.loadFailure(
    GithubFailure failure,
    Fresh<List<GithubRepo>> repos,
  ) = _Failure;
}

//only thing presentation layer should do is to get its states available from states union
class PaginatedReposNotifier extends StateNotifier<PaginatedReposState> {
  PaginatedReposNotifier()
      : super(
          PaginatedReposState.initial(
            Fresh.yes([]),
          ),
        );

  //sometimes mutable field using directly in class is fine
  int _page = 1;

  @protected
  void resetState() {
    _page = 1;
    state = PaginatedReposState.initial(Fresh.yes([]));
  }

//it should be only called from the subclasses,by mark it as protected which comes from meta package
  @protected
  Future<void> getNextPage(RepositoryGetter getter) async {
    state = PaginatedReposState.loadInProgress(
      state.repos,
      PaginationConfig.itemsPerPage,
    );
    final failureOrRepos = await getter(_page);
    state = failureOrRepos.fold(
      //not increment the page unless successful
      (l) => PaginatedReposState.loadFailure(l, state.repos),
      (r) {
        _page++;
        return PaginatedReposState.loadSuccess(
          r.copyWith(
            entity: [...state.repos.entity, ...r.entity],
          ),
          isNextPageAvailable: r.isNextPageAvailable ?? false,
        );
      },
    );
  }
}
