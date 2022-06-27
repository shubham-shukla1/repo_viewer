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

class StarredReposRemoteService extends ReposRemoteService {
//inside infrastructure

  StarredReposRemoteService(Dio dio, GithubHeadersCache headersCache)
      : super(dio, headersCache);

//get starred repos from github api
  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredReposPage(
          int page) async
      //comment these hardcoded token and header , coz token is added in the auth interceptor
      //and accept header is added in base option
      // final acceptHeader = 'application/vnd.github.v3.html+json';

      =>
      super.getPage(
          requestUri: Uri.https(
            'api.github.com',
            '/user/starred',
            {
              'page': '$page',
              'per_page': PaginationConfig.itemsPerPage.toString(),
            },
          ),
          jsonDataSelector: (json) => json as List<dynamic>);
}
