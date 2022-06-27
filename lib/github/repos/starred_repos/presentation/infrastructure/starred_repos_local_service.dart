import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:sembast/sembast.dart';
import 'package:collection/collection.dart';

import '../../../../../core/infrastrcture/sembast_databse.dart';
import '../../../../core/infrastructure/pagination_config.dart';

class StarredReposLocalService {
  final SembastDatabase _sembastDatabase;
  final _store = intMapStoreFactory.store('starredRepos');

  StarredReposLocalService(this._sembastDatabase);
//update and insert page, we need to get the page of GithubRepoDto out of local service
  Future<void> upsertPage(List<GithubRepoDTO> dtos, int page) async {
    // for sembast we are using page from zero
    final sembastPage = page - 1;
//sembast support pagination out of box
    await _store
        .records(
          dtos.mapIndexed((index, _) =>
              index + PaginationConfig.itemsPerPage * sembastPage),
        )
        .put(
          _sembastDatabase.instance,
          dtos.map((e) => e.toJson()).toList(),
        );
  }

   Future<List<GithubRepoDTO>> getPage(int page) async {
    final sembastPage = page - 1;
// find record of snapshot
    final records = await _store.find(
      _sembastDatabase.instance,
      finder: Finder(
        //limit - limits the item out of database
        limit: PaginationConfig.itemsPerPage,
        //starts at 0 ,offset like 3*1..3*2...
        offset: PaginationConfig.itemsPerPage * sembastPage,
      ),
    );
    return records.map((e) => GithubRepoDTO.fromJson(e.value)).toList();
  }

  Future<int> getLocalPageCount() async {
    final repoCount = await _store.count(_sembastDatabase.instance);
    return (repoCount / PaginationConfig.itemsPerPage).ceil();
  } 
}
