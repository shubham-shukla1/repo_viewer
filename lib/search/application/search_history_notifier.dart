import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/search/infrastructure/search_history_repository.dart';
//By using [AsyncValue], you are guaranteed that you cannot forget to handle the loading/error state of an asynchronous operation.

//It also expose some utilities to nicely convert an [AsyncValue] to a different object. For example, a Flutter Widget may use [when] to convert an [AsyncValue] into either a progress indicator, an error screen, or to show the data:

//AsyncValue comes with loading,error,data state , do not need custom state
//it is a freezed class
class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final SearchHistoryRepository _repository;
//as no initial state in async value, we say loading
  SearchHistoryNotifier(this._repository) : super(const AsyncValue.loading());

//listen to the stream coming from the repository  and transform it into states,return type void

  void watchSearchTerms({String? filter}) {
    _repository.watchSearchTerms(filter: filter).listen((data) {
      state = AsyncValue.data(data);
    }, onError: (Object error) {
      state = AsyncValue.error(error);
    });
  }

  Future<void> addSearchTerms(String term) => _repository.addSearchTerms(term);

  Future<void> deleteSearchTerms(String term) =>
      _repository.deleteSearchTerms(term);

  Future<void> putSearchTermFirst(String term) =>
      _repository.putSearchTermFirst(term);
}
