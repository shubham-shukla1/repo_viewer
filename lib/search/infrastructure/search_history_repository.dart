import 'package:repo_viewer/core/infrastrcture/sembast_databse.dart';
import 'package:sembast/sembast.dart';

class SearchHistoryRepository {
  final SembastDatabase _sembastDatabase;
  //We are going to store string not some map

  final _store = StoreRef<int, String>('searchHistory');
  SearchHistoryRepository(this._sembastDatabase);
  static const historyLength = 10;

  //we need to get search terms, add,and delete search terms
  //and also get the search terms out of history list in a sorted way
  //so that the last used ones are displayed first and also we are adding
  //new search terms over the history length ,limit, delete the last used ones

  //Q> Get the search terms out of the database just once  or should we watch them
  //so that instead of having the return type of future list of string
  //or steam of list string, stream will produce the new values whenever history is updated
  //ui needs to updated , whenever search term is deleted so we have 2 options
  //1> we can either delete the search term manually and get the search term manually
  // 2>  if we are watching the history list through a stream we just call the watch function once
  //and then whenever data is changes watch method does not need to be called anymore because it is
  ////already watching  the history list, simply stream will give us a new list of string
  // it is also applied to filter the search term
//by default no filter will be passed , so make it nullable

  Stream<List<String>> watchSearchTerms({String? filter}) {
    //Stream<RecordSnapshot<int, String>?> onSnapshot
    return _store
        .query(
            finder: filter != null && filter.isNotEmpty
                ? Finder(
                    filter: Filter.custom(
                      (record) => record.value.toString().startsWith(filter),
                    ),
                  )
                : null)
        .onSnapshots(_sembastDatabase.instance)
        .map(
          (records) => records.reversed.map((e) => e.value).toList(),
        );
  }

//Not exposing the private methods, details will be in private methods so don not worry about the implementation when accessing

  Future<void> addSearchTerms(String term) =>
      _addSearchTerms(term, _sembastDatabase.instance);

  Future<void> deleteSearchTerms(String term) =>
      _deleteSearchTerms(term, _sembastDatabase.instance);

  Future<void> putSearchTermFirst(String term) async {
    //whenever doing these kind of multiple database operations
    //very close to each optimize using db transaction
    await _sembastDatabase.instance.transaction((transaction) async {
      await _deleteSearchTerms(term, transaction);
      await _addSearchTerms(term, transaction);
    });
  }

//whenever calling add search terms, should check if it is already exist in history ,
//do not add it

  Future<void> _addSearchTerms(
      String term, DatabaseClient databaseClient) async {
    final existingKey = await _store.findKey(
      databaseClient,
      finder: Finder(
        filter: Filter.custom(
          ((record) => record.value == term),
        ),
      ),
    );
    if (existingKey != null) {
      putSearchTermFirst(term);
      return;
    }

    await _store.add(databaseClient, term);
    final count = await _store.count(_sembastDatabase.instance);
    if (count > historyLength) {
      await _store.delete(
        _sembastDatabase.instance,
        finder: Finder(limit: count - historyLength),
      );
    }
  }

  Future<void> _deleteSearchTerms(
      String term, DatabaseClient databaseClient) async {
    await _store.delete(databaseClient,
        finder: Finder(
          filter: Filter.custom((record) => record.value == term),
        ));
  }
}
