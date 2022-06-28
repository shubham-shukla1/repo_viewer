import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/toast.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/core/presentation/failure_repo_tile.dart';
import 'package:repo_viewer/github/repos/core/presentation/repo_tile.dart';

import 'loading_repo_tile.dart';

class PaginatedReposListView extends ConsumerStatefulWidget {
  final AutoDisposeStateNotifierProvider<PaginatedReposNotifier, PaginatedReposState>
      paginatedReposNotifierProvider;

  final void Function(WidgetRef ref) getNextPage;

  final String noResultMessage;

  const PaginatedReposListView(
      {required this.paginatedReposNotifierProvider,
      required this.getNextPage,
      required this.noResultMessage,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaginatedReposListViewState();
}

class _PaginatedReposListViewState
    extends ConsumerState<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  Widget build(BuildContext context) {
    //ref.watch loads every time something happen but ref.listen to the condition

    final state = ref.watch(widget.paginatedReposNotifierProvider);
    ref.listen<PaginatedReposState>(widget.paginatedReposNotifierProvider,
        (previous, next) {
      next.map(
        initial: (_) => canLoadNextPage = true,
        //we do not need to load the next page if apge is already in loading
        loadInProgress: (_) => canLoadNextPage = false,
        loadSuccess: (_) => canLoadNextPage = _.isNextPageAvailable,
        loadFailure: (_) => canLoadNextPage = false,
      );
    });
    return NotificationListener<ScrollNotification>(
        //Return true to cancel the notification bubbling.
        // Return false to allow the notification to continue to be dispatched to further ancestors.
        onNotification: (notification) {
          final metrics = notification.metrics;
          //maxScrollExtent is the amount of pixels which are in total in the listView in the scroll direction
          //view port dimension which are visible to the user at once,from below appbar to end of screen
          //so maxScrollContent will always be greater
          final limit = metrics.maxScrollExtent - metrics.viewportDimension / 3;
          if (canLoadNextPage && metrics.pixels >= limit) {
            if (!state.repos.isFresh && !hasAlreadyShownNoConnectionToast) {
              showNoConnectionToast(
                  "You are not online,Some Information may be outdated",
                  context);
            }
            canLoadNextPage = false;
            //we should never call infrastructure from presentation
            widget.getNextPage(ref);

            /*  ref
                .read(widget.paginatedReposNotifierProvider.notifier)
                .getNextPage(); */
          }

          return false;
        },
        child:
            //show no list only when the load success happen otherwise no results display will be displayed
            state.maybeWhen(
          orElse: () => false,
          loadSuccess: (repos, _) => repos.entity.isEmpty,
        )
                ?  NoResultsDisplay(
                    message:
                       widget.noResultMessage)
                : _PaginatedListView(state: state));
  }
}
//only reason for extracting is that it will become too long,also the package private

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final PaginatedReposState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.map(
        initial: (_) => 0,
        loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
        loadSuccess: (_) => _.repos.entity.length,
        loadFailure: (_) =>

            //if failure occurs we want to load the previous list
            _.repos.entity.length + 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return state.map(
            initial: (_) => Container(),
            loadInProgress: (_) {
              if (index < _.repos.entity.length) {
                return RepoTile(repo: _.repos.entity[index]);
              } else {
                //when load in progress we are going to show shimmer,
                // instead of text or images for some time
                return const LoadingRepoTile();
              }
            },
            loadSuccess: (_) => RepoTile(repo: _.repos.entity[index]),
            loadFailure: (_) {
              if (index < _.repos.entity.length) {
                return RepoTile(repo: _.repos.entity[index]);
              } else {
                return FailureRepoTile(failure: _.failure);
              }
            });
      },
    );
  }
}
