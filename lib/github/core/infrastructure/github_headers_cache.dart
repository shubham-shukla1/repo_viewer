import 'package:repo_viewer/core/infrastrcture/sembast_databse.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';
import 'package:sembast/sembast.dart';

class GithubHeadersCache {
  //Need Sembast Database class for saving ,delete etc
  //sembast has store because the instance has no store  _sembastDatabase.instance.
  final SembastDatabase _sembastDatabase;
  final _store = stringMapStoreFactory.store('headers');

  GithubHeadersCache(this._sembastDatabase);

//key is Uri
  Future<void> saveHeaders(Uri uri, GithubHeaders githubHeaders) async {
    //provide the  databse to the record method
    await _store
        .record(uri.toString())
        .put(_sembastDatabase.instance, githubHeaders.toJson());

    //different headers for different url
  }

  //to retrieve  the headers from database,uri
  Future<GithubHeaders?> getHeaders(Uri uri) async {
    //Map<String, Object?> is  actually json
    final json =
        await _store.record(uri.toString()).get(_sembastDatabase.instance);
    //parse json into GithubHeaders class
    //can only parse non  nullable map
    return json == null ? null : GithubHeaders.fromJson(json);
  }

  Future<void> deleteHeaders(Uri uri) async {
    await _store.record(uri.toString()).delete(_sembastDatabase.instance);
  }
}
