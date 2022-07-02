import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/infrastructure/starred_repos_repositorry.dart';

//only thing presentation layer should do is to get its states available from states union
class StarredReposNotifier extends PaginatedReposNotifier {
  final StarredReposRepository _repository;

  StarredReposNotifier(this._repository);
  //sometimes mutable field using directly in class is fine
  // int _page = 1;
  Future<void> getFirstStarredReposPage() async {
    super.resetState();
    await getNextStarredReposPage();
  }

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
