import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

import '../../../../core/presentation/routes/app_router.gr.dart';
import '../../core/presentation/paginated_repos_list_view.dart';

class SearchedReposPage extends ConsumerStatefulWidget {
  final String searchTerm;
  const SearchedReposPage({required this.searchTerm, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchedReposPageState();
}

class _SearchedReposPageState extends ConsumerState<SearchedReposPage> {
  @override
  void initState() {
    ref
        .read(searchedReposNotifierProvider.notifier)
        .getNextSearchedReposPage(widget.searchTerm);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SearchBar(
        title: widget.searchTerm,
        hint: 'Search all repositories...',
        onShouldNavigateToResultPage: (searchTerm) {
          //when call replace the page is same as replacement page then new instance of this page is not really created
          //init state will not run again, we need to first pop
          AutoRouter.of(context).pushAndPopUntil(
            SearchedReposRoute(searchTerm: searchTerm),
            predicate: (route) => route.settings.name == StarredReposRoute.name,
            // predicate: (Route<dynamic> route) => false,this will pop all of routes ,we only want to pop until
          );
        },
        onSignOutButtonPressed: () {
          ref.read(authNotifierProvider.notifier).signOut();
        },
        body: PaginatedReposListView(
          paginatedReposNotifierProvider: searchedReposNotifierProvider,
          getNextPage: (ref) => ref
              .read(searchedReposNotifierProvider.notifier)
              .getNextSearchedReposPage(widget.searchTerm),
          noResultMessage: "This is all we could find for search Term",
        ),
      ),
    );
  }
}
