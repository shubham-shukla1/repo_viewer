import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repo_remote_service.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_repository.dart';

import '../../../core/shared/providers.dart';
import '../../repos/core/application/paginated_repos_notifier.dart';
import '../../repos/searched_repos/application/searched_repos_notifier.dart';
import '../../repos/starred_repos/presentation/application/starred_repos_notifier.dart';
import '../../repos/starred_repos/presentation/infrastructure/starred_repos_local_service.dart';
import '../../repos/starred_repos/presentation/infrastructure/starred_repos_remote_service.dart';
import '../../repos/starred_repos/presentation/infrastructure/starred_repos_repositorry.dart';
import '../infrastructure/github_headers_cache.dart';

final githubHeadersCacheProvider = Provider(
  (ref) => GithubHeadersCache(ref.watch(sembastProvider)),
);

final starredReposLocalServiceProvider = Provider(
  (ref) => StarredReposLocalService(ref.watch(sembastProvider)),
);

final starredReposRemoteServiceProvider = Provider(
  (ref) => StarredReposRemoteService(
    ref.watch(dioProvider),
    ref.watch(githubHeadersCacheProvider),
  ),
);

final starredReposRepositoryProvider = Provider(
  (ref) => StarredReposRepository(
    ref.watch(starredReposRemoteServiceProvider),
    ref.watch(starredReposLocalServiceProvider),
  ),
);

final starredReposNotifierProvider = StateNotifierProvider<
    StarredReposNotifier, PaginatedReposState>(
  (ref) => StarredReposNotifier(ref.watch(starredReposRepositoryProvider)),
);

//Create providers for all the classes we need
final searchedReposRemoteServiceProvider = Provider(
  (ref) => SearchedRepoRemoteService(
    //it also depends on dio and github headers cache,arguments same
    ref.watch(dioProvider),
    ref.watch(githubHeadersCacheProvider),
  ),
);

final searchedReposRepositoryProvider = Provider(
  (ref) => SearchedReposRepository(
    ref.watch(searchedReposRemoteServiceProvider),
  ),
);

final searchedReposNotifierProvider = StateNotifierProvider<
    SearchedReposNotifier, PaginatedReposState>(
  (ref) => SearchedReposNotifier(ref.watch(searchedReposRepositoryProvider)),
);
