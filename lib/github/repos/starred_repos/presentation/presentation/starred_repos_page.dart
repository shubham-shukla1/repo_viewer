import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/searched_repos/presentation/searched_repos_page.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

import '../../../../../core/presentation/routes/app_router.gr.dart';
import '../../../core/presentation/paginated_repos_list_view.dart';

class StarredReposPage extends ConsumerStatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StarredReposPageState();
}

class _StarredReposPageState extends ConsumerState<StarredReposPage> {
  @override
  void initState() {
    //wait a bit to read the notifier,schedule the call to happen in future
    //but not to much as soon as possible after init state has run successfully
    //scheduling the call using microtask
    ref.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
//Other ways
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {ref.read(provider)});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        onShouldNavigateToResultPage: (searchTerm) {
          AutoRouter.of(context)
              .push(SearchedReposRoute(searchTerm: searchTerm));
        },
        title: "Starred Repository",
        hint: "Search all repositories...",
        body: PaginatedReposListView(
          paginatedReposNotifierProvider: starredReposNotifierProvider,
          getNextPage: (ref) => ref
              .read(starredReposNotifierProvider.notifier)
              .getNextStarredReposPage(),
          noResultMessage: "Thats about everything we could find for right now",
        ),
        onSignOutButtonPressed: () {
          ref.read(authNotifierProvider.notifier).signOut();
        },
      ),
    );
  }
}
