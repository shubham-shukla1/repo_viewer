import 'package:repo_viewer/github/repos/core/infrastructure/repos_remote_service.dart';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastrcture/networ_exception.dart';
import 'package:repo_viewer/core/infrastrcture/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/core/infrastrcture/dio_extension.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/repos_remote_service.dart';

class SearchedRepoRemoteService extends ReposRemoteService {
  SearchedRepoRemoteService(Dio dio, GithubHeadersCache headersCache)
      : super(dio, headersCache);
  Future<RemoteResponse<List<GithubRepoDTO>>> getSearchedReposPage(String query,
          int page) async =>
      super.getPage(
          requestUri: Uri.https(
            'api.github.com',
            '/search/repositories',
            {
              'q':query,
              'page': '$page',
              'per_page': PaginationConfig.itemsPerPage.toString(),
            },
          ),
          jsonDataSelector: (json) => json['items'] as List<dynamic>);
}
