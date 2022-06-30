import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  @override
  void initState() {
    ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
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
      builder: (context, transition) {
        return Container();
      },
    );
  }
}
