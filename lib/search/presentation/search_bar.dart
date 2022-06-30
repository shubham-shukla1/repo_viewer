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
      body: widget.body,
      title: Text(widget.title),
      hint: widget.hint,
      builder: (context,transition) {
        return Container();
      },
    );
  }
}
