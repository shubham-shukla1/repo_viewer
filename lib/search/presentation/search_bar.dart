import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends ConsumerStatefulWidget {
  final Widget body;
  final String title;
  final String hint;
  final void Function(String searchTerm) onShouldNavigateToResultPage;
  final void Function() onSignOutButtonPressed;

  const SearchBar(
      {required this.body,
      required this.title,
      required this.hint,
      required this.onShouldNavigateToResultPage,
      required this.onSignOutButtonPressed,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late FloatingSearchBarController _controller;

  @override
  void initState() {
    _controller = FloatingSearchBarController();
    ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms();
    super.initState();
  }

//dispose controllers
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //we do not need to create this method inside of the class no wrong in that
    // we can call this method only from the build method,its useful
    void pushPageAndPutFirstInHistory(String searchTerm) {
      widget.onShouldNavigateToResultPage(searchTerm);
      ref
          .read(searchHistoryNotifierProvider.notifier)
          .putSearchTermFirst(searchTerm);
      _controller.close();
    }

    void pushPageAndAddToHistory(String searchTerm) {
      widget.onShouldNavigateToResultPage(searchTerm);
      ref
          .read(searchHistoryNotifierProvider.notifier)
          .addSearchTerms(searchTerm);
      _controller.close();
    }

    return FloatingSearchBar(
      controller: _controller,
      //in which the search bar is hidden
      /// when the user scrolls down and shown again when the user scrolls up
      //it also have the return widget scroll notification

      body: FloatingSearchBarScrollNotifier(child: widget.body),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //column take up only necessary amount not full height using size
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),

          //for emoji: on mac control alt space and on windows windows dot
          Text('Tap to search 👆', style: Theme.of(context).textTheme.caption),
        ],
      ),
      hint: widget.hint,
      automaticallyImplyBackButton: false,
      leadingActions: [
        if (AutoRouter.of(context).canPopSelfOrChildren &&
            (Platform.isIOS || Platform.isMacOS))
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            splashRadius: 18,
            onPressed: () {
              AutoRouter.of(context).pop();
            },
          )
        else if (AutoRouter.of(context).canPopSelfOrChildren)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            splashRadius: 18,
            onPressed: () {
              AutoRouter.of(context).pop();
            },
          )
      ],
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          child: IconButton(
            icon: const Icon(MdiIcons.logoutVariant),
            splashRadius: 18,
            onPressed: () {
              widget.onSignOutButtonPressed();
            },
          ),
        ),
      ],
      onQueryChanged: (query) {
        ref
            .read(searchHistoryNotifierProvider.notifier)
            .watchSearchTerms(filter: query);
      },
      //onSubmitted Callback will run whenever the query is submitted
      onSubmitted: (query) {
       pushPageAndAddToHistory(query);
      },
      builder: (context, transition) {
        final searchHistoryState = ref.watch(searchHistoryNotifierProvider);
        return searchHistoryState.map(
          data: (history) {
            if (_controller.query.isEmpty && history.value.isEmpty) {
              return MaterialWidget(
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Text(
                    'Start searching',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              );
            } else if (history.value.isEmpty) {
              return MaterialWidget(
                child: ListTile(
                  title: Text(_controller.query),
                  leading: const Icon(Icons.search),
                  onTap: () {
                    pushPageAndAddToHistory(_controller.query);
                  },
                ),
              );
            }
            return MaterialWidget(
              child: Column(
                children: history.value
                    .map(
                      (term) => ListTile(
                        title: Text(
                          term,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: const Icon(Icons.history),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref
                                .read(searchHistoryNotifierProvider.notifier)
                                .deleteSearchTerms(term);
                          },
                        ),
                        onTap: () {
                          pushPageAndPutFirstInHistory(term);
                        },
                      ),
                    )
                    .toList(),
              ),
            );
          },
          loading: (_) => const ListTile(
            title: LinearProgressIndicator(),
          ),
          error: (_) => ListTile(
            title: Text('Very unexpected error ${_.error}'),
          ),
        );
      },
    );
  }
}

class MaterialWidget extends StatelessWidget {
  final Widget child;
  const MaterialWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}
