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

//signout from the app,and come back starred repos  are freshly gotten ,coz without auto
//dispose modifier, after sign out, login with another account we will still see the previous repos

final starredReposNotifierProvider = StateNotifierProvider.autoDispose<
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
//By default riverpod provider hold the instance which they create it in memory
//until the app is fully closed
//previously results were hold, by default object provided by riverpod are not disposed
 //when they are not in use then auto dispose,once we are away from that page
final searchedReposNotifierProvider = StateNotifierProvider.autoDispose<
    SearchedReposNotifier, PaginatedReposState>(
  (ref) => SearchedReposNotifier(ref.watch(searchedReposRepositoryProvider)),
);
