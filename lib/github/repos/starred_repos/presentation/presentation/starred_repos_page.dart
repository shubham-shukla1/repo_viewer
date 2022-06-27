import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';

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
    Future.microtask(
      () => ref
          .read(starredReposNotifierProvider.notifier)
          .getNextStarredReposPage(),
    );
//Other ways
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {ref.read(provider)});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Page"),
        actions: [
          IconButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
              icon: const Icon(MdiIcons.loginVariant))
        ],
      ),
      body: PaginatedReposListView(
        paginatedReposNotifierProvider: starredReposNotifierProvider,
        getNextPage: (ref) => ref
            .read(starredReposNotifierProvider.notifier)
            .getNextStarredReposPage(),
            noResultMessage:  "Thats about everything we could find for right now",
      ),
    );
  }
}
