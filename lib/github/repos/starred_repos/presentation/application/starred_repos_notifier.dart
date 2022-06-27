import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/infrastructure/starred_repos_repositorry.dart';

import '../../../../../core/domain/fresh.dart';
import '../../../../core/domain/github_repo.dart';

//only thing presentation layer should do is to get its states available from states union
class StarredReposNotifier extends PaginatedReposNotifier {
  final StarredReposRepository _repository;

  StarredReposNotifier(this._repository);
  //sometimes mutable field using directly in class is fine
  // int _page = 1;
  Future<void> getNextStarredReposPage() async {
    super.getNextPage((page) => _repository.getStarredReposPage(page));
    /*  state = StarredReposState.loadInProgress(
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
    );*/
  }
}
